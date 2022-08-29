//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling

class CallingSDKWrapper: NSObject, CallingSDKWrapperProtocol {
    let callingEventsHandler: CallingSDKEventsHandling

    // Helper to access the specialized version. Swift doesn't do generic protocols
    internal var eventHandler: CallingSDKEventsHandler! {
        callingEventsHandler as? CallingSDKEventsHandler
    }
    internal let logger: Logger

    // Call setup
    internal let callConfiguration: CallConfiguration
    internal var callClient: CallClient?
    internal var callAgent: CallAgent?
    internal var call: Call?
    internal var deviceManager: DeviceManager?

    // Video handling
    internal var localVideoStream: LocalVideoStream?

    private struct VideoStreamCache {
        var renderer: VideoStreamRenderer
        var rendererView: RendererView
        var mediaStreamType: MediaStreamType
    }
    private var localRendererViews = MappedSequence<String, VideoStreamCache>()
    private var displayedRemoteParticipantsRendererView = MappedSequence<String, VideoStreamCache>()
    private var newVideoDeviceAddedHandler: ((VideoDeviceInfo) -> Void)?
    private var didRenderScreenShareFirstFrame: ((CGSize) -> Void)?

    init(logger: Logger,
         callingEventsHandler: CallingSDKEventsHandling,
         callConfiguration: CallConfiguration) {
        self.logger = logger
        self.callingEventsHandler = callingEventsHandler
        self.callConfiguration = callConfiguration
        super.init()
    }

    deinit {
        disposeViews()
        logger.debug("CallingSDKWrapper deallocated")
    }

    func stopLocalVideoStream() async throws {
        guard let call = self.call,
              let videoStream = self.localVideoStream else {
            logger.debug("Local video stopped successfully without call")
            return
        }
        do {
            try await call.stopVideo(stream: videoStream)
            logger.debug("Local video stopped successfully")
        } catch {
            logger.error( "Local video failed to stop. \(error)")
            throw error
        }
    }

    func getRemoteParticipantVideoRendererView(
        _ videoViewId: RemoteParticipantVideoViewId,
        sizeCallback: ((CGSize) -> Void)?)
    -> ParticipantRendererViewInfo? {

        let videoStreamId = videoViewId.videoStreamIdentifier
        let userIdentifier = videoViewId.userIdentifier
        let cacheKey = generateCacheKey(userIdentifier: videoViewId.userIdentifier,
                                        videoStreamId: videoStreamId)
        if let videoStreamCache = displayedRemoteParticipantsRendererView.value(forKey: cacheKey) {
            let streamSize = CGSize(width: Int(videoStreamCache.renderer.size.width),
                              height: Int(videoStreamCache.renderer.size.height))
            return ParticipantRendererViewInfo(rendererView: videoStreamCache.rendererView,
                                               streamSize: streamSize)
        }

        guard let participant = getRemoteAcsPartipant(userIdentifier),
              let videoStream = participant.videoStreams.first(where: { stream in
                  return String(stream.id) == videoStreamId
        }) else {
            return nil
        }

        do {
            let options = CreateViewOptions(scalingMode: videoStream.mediaStreamType == .screenSharing ? .fit : .crop)
            let newRenderer: VideoStreamRenderer = try VideoStreamRenderer(remoteVideoStream: videoStream)
            let newRendererView: RendererView = try newRenderer.createView(withOptions: options)

            let cache = VideoStreamCache(renderer: newRenderer,
                                         rendererView: newRendererView,
                                         mediaStreamType: videoStream.mediaStreamType)
            displayedRemoteParticipantsRendererView.append(forKey: cacheKey,
                                                           value: cache)

            if videoStream.mediaStreamType == .screenSharing {
                didRenderScreenShareFirstFrame = sizeCallback
                newRenderer.delegate = self
            }

            return ParticipantRendererViewInfo(rendererView: newRendererView, streamSize: .zero)
        } catch let error {
            logger.error("Failed to render remote video, reason:\(error.localizedDescription)")
            return nil
        }
    }

    func getRemoteParticipantVideoRendererViewSize() -> CGSize? {
        if let screenShare = displayedRemoteParticipantsRendererView.first(where: { cache in
            cache.mediaStreamType == .screenSharing
        }) {
            return CGSize(width: Int(screenShare.renderer.size.width), height: Int(screenShare.renderer.size.height))
        }

        return nil
    }

    func getLocalVideoStream(_ identifier: String) -> VideoStreamInfoModel? {
        guard getLocalVideoStreamIdentifier() == identifier else {
            return nil
        }
        return localVideoStream?.asVideoStream
    }

    func updateDisplayedLocalVideoStream(_ identifier: String?) {
        localRendererViews.makeKeyIterator().forEach { [weak self] key in
            if identifier != key {
                self?.disposeLocalVideoRendererCache(key)
            }
        }
    }

    func updateDisplayedRemoteVideoStream(_ videoViewIdArray: [RemoteParticipantVideoViewId]) {
        let displayedKeys = videoViewIdArray.map {
            return generateCacheKey(userIdentifier: $0.userIdentifier, videoStreamId: $0.videoStreamIdentifier)
        }

        displayedRemoteParticipantsRendererView.makeKeyIterator().forEach { [weak self] key in
            if !displayedKeys.contains(key) {
                self?.disposeRemoteParticipantVideoRendererView(key)
            }
        }
    }

    func getLocalVideoRendererView(_ identifier: String) throws -> UIView? {
        guard getLocalVideoStreamIdentifier() == identifier,
            let videoStream = localVideoStream else {
            return nil
        }
        let newRenderer: VideoStreamRenderer = try VideoStreamRenderer(localVideoStream: videoStream)
        let newRendererView: RendererView = try newRenderer.createView(
            withOptions: CreateViewOptions(scalingMode: .crop))

        let cache = VideoStreamCache(renderer: newRenderer,
                                     rendererView: newRendererView,
                                     mediaStreamType: videoStream.mediaStreamType)
        localRendererViews.append(forKey: identifier,
                                  value: cache)
        return newRendererView
    }

    func startPreviewVideoStream() async throws -> String {
        _ = await getValidLocalVideoStream()
        return getLocalVideoStreamIdentifier() ?? ""
    }

    func startCallLocalVideoStream() async throws -> String {
        let stream = await getValidLocalVideoStream()
        return try await startCallVideoStream(stream)
    }

    func switchCamera() async throws -> CameraDevice {
        guard let videoStream = localVideoStream else {
            let error = CallCompositeInternalError.cameraSwitchFailed
            logger.error("\(error)")
            throw error
        }
        let currentCamera = videoStream.source
        let flippedFacing: CameraFacing = currentCamera.cameraFacing == .front ? .back : .front

        let deviceInfo = await getVideoDeviceInfo(flippedFacing)
        try await change(videoStream, source: deviceInfo)
        return flippedFacing.toCameraDevice()
    }

    func getRemoteParticipant(_ identifier: String) -> ParticipantInfoModel? {
        getRemoteAcsPartipant(identifier)?.toParticipantInfoModel()
    }

    private func getRemoteAcsPartipant(_ identifier: String) -> RemoteParticipant? {
        guard let call = call else {
            return nil
        }

        return call.remoteParticipants.first(where: {
            $0.identifier.stringValue == identifier
        })
    }

    private func generateCacheKey(userIdentifier: String, videoStreamId: String) -> String {
        return ("\(userIdentifier):\(videoStreamId)")
    }

    private func getLocalVideoStreamIdentifier() -> String? {
        guard localVideoStream != nil else {
            return nil
        }
        return "builtinCameraVideoStream"
    }

    private func getValidLocalVideoStream() async -> LocalVideoStream {
        if let existingVideoStream = localVideoStream {
            return existingVideoStream
        }

        let videoDevice = await getVideoDeviceInfo(.front)
        let videoStream = LocalVideoStream(camera: videoDevice)
        localVideoStream = videoStream
        return videoStream
    }

    private func startCallVideoStream(_ videoStream: LocalVideoStream) async throws -> String {
        guard let call = self.call else {
            let error = CallCompositeInternalError.cameraOnFailed
            self.logger.error( "Start call video stream failed")
            throw error
        }
        do {
            let localVideoStreamId = getLocalVideoStreamIdentifier() ?? ""
            try await call.startVideo(stream: videoStream)
            logger.debug("Local video started successfully")
            return localVideoStreamId
        } catch {
            logger.error( "Local video failed to start. \(error)")
            throw error
        }
    }

    private func change(_ videoStream: LocalVideoStream, source: VideoDeviceInfo) async throws {
        do {
            try await videoStream.switchSource(camera: source)
            logger.debug("Local video switched camera successfully")
        } catch {
            logger.error( "Local video failed to switch camera. \(error)")
            throw error
        }
    }

    private func disposeViews() {
        displayedRemoteParticipantsRendererView.makeKeyIterator().forEach { key in
            self.disposeRemoteParticipantVideoRendererView(key)
        }
        localRendererViews.makeKeyIterator().forEach { key in
            self.disposeLocalVideoRendererCache(key)
        }
    }

    private func disposeRemoteParticipantVideoRendererView(_ cacheId: String) {
        if let renderer = displayedRemoteParticipantsRendererView.removeValue(forKey: cacheId) {
            renderer.renderer.dispose()
            renderer.renderer.delegate = nil
        }
    }

    private func disposeLocalVideoRendererCache(_ identifier: String) {
        if let renderer = localRendererViews.removeValue(forKey: identifier) {
            renderer.renderer.dispose()
        }
    }
}

extension CallingSDKWrapper: DeviceManagerDelegate {
    func deviceManager(_ deviceManager: DeviceManager, didUpdateCameras args: VideoDevicesUpdatedEventArgs) {
        for newDevice in args.addedVideoDevices {
            newVideoDeviceAddedHandler?(newDevice)
        }
    }

    func getVideoDeviceInfo(_ cameraFacing: CameraFacing) async -> VideoDeviceInfo {
        // If we have a camera, return the value right away
        await withCheckedContinuation({ continuation in
            if let camera = deviceManager?.cameras
                .first(where: { $0.cameraFacing == cameraFacing }
                ) {
                newVideoDeviceAddedHandler = nil
                return continuation.resume(returning: camera)
            }
            newVideoDeviceAddedHandler = { deviceInfo in
                if deviceInfo.cameraFacing == cameraFacing {
                    continuation.resume(returning: deviceInfo)
                }
            }
        })
    }
}

 extension CallingSDKWrapper: RendererDelegate {
    func videoStreamRenderer(didRenderFirstFrame renderer: VideoStreamRenderer) {
        let size = CGSize(width: Int(renderer.size.width), height: Int(renderer.size.height))
        didRenderScreenShareFirstFrame?(size)
    }

    func videoStreamRenderer(didFailToStart renderer: VideoStreamRenderer) {
        logger.error("Failed to render remote screenshare video. \(renderer)")
    }
 }

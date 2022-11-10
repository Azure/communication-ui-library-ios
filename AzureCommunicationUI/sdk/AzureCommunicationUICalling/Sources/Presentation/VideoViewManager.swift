//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

import Foundation

struct RemoteParticipantVideoViewId {
    let userIdentifier: String
    let videoStreamIdentifier: String
}

struct ParticipantRendererViewInfo {
    let rendererView: UIView
    let streamSize: CGSize
}

protocol RendererViewManager: AnyObject {
    var didRenderFirstFrame: ((CGSize) -> Void)? { get set }

    func getRemoteParticipantVideoRendererView
    (_ videoViewId: RemoteParticipantVideoViewId) -> ParticipantRendererViewInfo?
    func getRemoteParticipantVideoRendererViewSize() -> CGSize?
}

class VideoViewManager: NSObject, RendererDelegate, RendererViewManager {

    struct VideoStreamCache {
        var renderer: VideoStreamRenderer
        var rendererView: RendererView
        var mediaStreamType: CompositeMediaStreamType
    }
    private let logger: Logger
    private var displayedRemoteParticipantsRendererView = MappedSequence<String, VideoStreamCache>()

    private var localRendererViews = MappedSequence<String, VideoStreamCache>()

    private let callingSDKWrapper: CallingSDKWrapperProtocol

    init(callingSDKWrapper: CallingSDKWrapperProtocol,
         logger: Logger) {
        self.callingSDKWrapper = callingSDKWrapper
        self.logger = logger
    }

    deinit {
        disposeViews()
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

    func updateDisplayedLocalVideoStream(_ identifier: String?) {
        localRendererViews.makeKeyIterator().forEach { [weak self] key in
            if identifier != key {
                self?.disposeLocalVideoRendererCache(key)
            }
        }
    }

    func getLocalVideoRendererView(_ videoStreamId: String) -> UIView? {
        if let localRenderCache = localRendererViews.value(forKey: videoStreamId) {
            return localRenderCache.rendererView
        }

        guard let videoStream: CompositeLocalVideoStream<AzureCommunicationCalling.LocalVideoStream> =
                callingSDKWrapper.getLocalVideoStream(videoStreamId) else {
            return nil
        }
        let wrappedVideoStream = videoStream.wrappedObject
        do {
            let newRenderer: VideoStreamRenderer = try VideoStreamRenderer(localVideoStream: wrappedVideoStream)
            let newRendererView: RendererView = try newRenderer.createView(
                withOptions: CreateViewOptions(scalingMode: .crop))

            let cache = VideoStreamCache(
                renderer: newRenderer,
                rendererView: newRendererView,
                mediaStreamType: videoStream.mediaStreamType
            )
            localRendererViews.append(forKey: videoStreamId,
                                      value: cache)
            return newRendererView
        } catch let error {
            logger.error("Failed to render remote video, reason:\(error.localizedDescription)")
            return nil
        }

    }

    // MARK: ParticipantRendererViewManager

    var didRenderFirstFrame: ((CGSize) -> Void)?

    func getRemoteParticipantVideoRendererView(_ videoViewId: RemoteParticipantVideoViewId)
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

        guard let participant: CompositeRemoteParticipant< AzureCommunicationCalling.RemoteParticipant,
                                                  AzureCommunicationCalling.RemoteVideoStream> =
                callingSDKWrapper.getRemoteParticipant(userIdentifier),
              let videoStream = participant.videoStreams.first(where: { stream in
                  return String(stream.id) == videoStreamId
              }) else {
            return nil
        }

        let wrappedVideoStream = videoStream.wrappedObject
        do {
            let options = CreateViewOptions(scalingMode: videoStream.mediaStreamType == .screenSharing ? .fit : .crop)
            let newRenderer: VideoStreamRenderer = try VideoStreamRenderer(remoteVideoStream: wrappedVideoStream)
            let newRendererView: RendererView = try newRenderer.createView(withOptions: options)

            let cache = VideoStreamCache(renderer: newRenderer,
                                         rendererView: newRendererView,
                                         mediaStreamType: videoStream.mediaStreamType)
            displayedRemoteParticipantsRendererView.append(forKey: cacheKey,
                                                           value: cache)

            if videoStream.mediaStreamType == .screenSharing {
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

    // MARK: Helper functions

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

    private func generateCacheKey(userIdentifier: String, videoStreamId: String) -> String {
        return ("\(userIdentifier):\(videoStreamId)")
    }

    // MARK: RendererDelegate

    func videoStreamRenderer(didRenderFirstFrame renderer: VideoStreamRenderer) {
        let size = CGSize(width: Int(renderer.size.width), height: Int(renderer.size.height))
        didRenderFirstFrame?(size)
    }

    func videoStreamRenderer(didFailToStart renderer: VideoStreamRenderer) {
        logger.error("Failed to render remote screenshare video. \(renderer)")
    }
}

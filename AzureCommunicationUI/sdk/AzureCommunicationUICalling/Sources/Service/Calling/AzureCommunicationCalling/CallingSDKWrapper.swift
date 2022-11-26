//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

import Combine
import Foundation

class CallingSDKWrapper: NSObject, CallingSDKWrapperProtocol {
    let callingEventsHandler: CallingSDKEventsHandling

    private let logger: Logger
    private let callConfiguration: CallConfiguration
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var localVideoStream: AzureCommunicationCalling.LocalVideoStream?

    private var newVideoDeviceAddedHandler: ((VideoDeviceInfo) -> Void)?

    init(logger: Logger,
         callingEventsHandler: CallingSDKEventsHandling,
         callConfiguration: CallConfiguration) {
        self.logger = logger
        self.callingEventsHandler = callingEventsHandler
        self.callConfiguration = callConfiguration
        super.init()
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    func setupCall() async throws {
        try await setupCallClientAndDeviceManager()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug("Reset Subjects in callingEventsHandler")
        if let callingEventsHandler = self.callingEventsHandler
            as? CallingSDKEventsHandler {
            callingEventsHandler.setupProperties()
        }
        logger.debug( "Starting call")
        do {
            try await setupCallAgent()
        } catch {
            throw CallCompositeInternalError.callJoinFailed
        }
        try await joinCall(isCameraPreferred: isCameraPreferred, isAudioPreferred: isAudioPreferred)
    }

    func joinCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug( "Joining call")
        let joinCallOptions = JoinCallOptions()

        if isCameraPreferred,
           let localVideoStream = localVideoStream {
            let localVideoStreamArray = [localVideoStream]
            let videoOptions = VideoOptions(localVideoStreams: localVideoStreamArray)
            joinCallOptions.videoOptions = videoOptions
        }

        joinCallOptions.audioOptions = AudioOptions()
        joinCallOptions.audioOptions?.muted = !isAudioPreferred

        var joinLocator: JoinMeetingLocator
        if callConfiguration.compositeCallType == .groupCall,
           let groupId = callConfiguration.groupId {
            joinLocator = GroupCallLocator(groupId: groupId)
        } else if let meetingLink = callConfiguration.meetingLink {
            joinLocator = TeamsMeetingLinkLocator(meetingLink: meetingLink)
        } else {
            logger.error("Invalid groupID / meeting link")
            throw CallCompositeInternalError.callJoinFailed
        }

        let joinedCall = try await callAgent?.join(with: joinLocator, joinCallOptions: joinCallOptions)

        guard let joinedCall = joinedCall else {
            logger.error( "Join call failed")
            throw CallCompositeInternalError.callJoinFailed
        }

        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
            joinedCall.delegate = callingEventsHandler
        }
        call = joinedCall
        setupCallRecordingAndTranscriptionFeature()
    }

    func endCall() async throws {
        guard call != nil else {
            throw CallCompositeInternalError.callEndFailed
        }
        do {
            try await call?.hangUp(options: HangUpOptions())
            logger.debug("Call ended successfully")
        } catch {
            logger.error( "It was not possible to hangup the call.")
            throw error
        }
    }

    func getRemoteParticipant<ParticipantType, StreamType>(_ identifier: String)
    -> CompositeRemoteParticipant<ParticipantType, StreamType>? {
        guard let remote = findParticipant(identifier: identifier) else {
            return nil
        }

        let remoteParticipant = AzureCommunicationCalling.RemoteParticipant
            .toCompositeRemoteParticipant(acsRemoteParticipant: remote)
        guard let castValue = remoteParticipant as? CompositeRemoteParticipant<ParticipantType, StreamType> else {
            return nil
        }
        return castValue
    }

    private func findParticipant(identifier: String) -> AzureCommunicationCalling.RemoteParticipant? {
        call?.remoteParticipants.first(where: { $0.identifier.rawId == identifier })
    }

    func getLocalVideoStream<LocalVideoStreamType>(_ identifier: String)
    -> CompositeLocalVideoStream<LocalVideoStreamType>? {

        guard getLocalVideoStreamIdentifier() == identifier else {
            return nil
        }
        guard let videoStream = localVideoStream,
              let castVideoStream = videoStream as? LocalVideoStreamType else {
            return nil
        }
        guard videoStream is LocalVideoStreamType else {
            return nil
        }
        return CompositeLocalVideoStream(
            mediaStreamType: videoStream.mediaStreamType.asCompositeMediaStreamType,
            wrappedObject: castVideoStream
        )
    }

    func startCallLocalVideoStream() async throws -> String {
        let stream = await getValidLocalVideoStream()
        return try await startCallVideoStream(stream)
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

    func startPreviewVideoStream() async throws -> String {
        _ = await getValidLocalVideoStream()
        return getLocalVideoStreamIdentifier() ?? ""
    }

    func muteLocalMic() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.mute()
        } catch {
            logger.error("ERROR: It was not possible to mute. \(error)")
            throw error
        }
        logger.debug("Mute successful")
    }

    func unmuteLocalMic() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.unmute()
        } catch {
            logger.error("ERROR: It was not possible to unmute. \(error)")
            throw error
        }
        logger.debug("Unmute successful")
    }

    func holdCall() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.hold()
            logger.debug("Hold Call successful")
        } catch {
            logger.error("ERROR: It was not possible to hold call. \(error)")
        }
    }

    func resumeCall() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.resume()
            logger.debug("Resume Call successful")
        } catch {
            logger.error( "ERROR: It was not possible to resume call. \(error)")
            throw error
        }
    }
}

extension CallingSDKWrapper {
    private func setupCallClientAndDeviceManager() async throws {
        do {
            let client = makeCallClient()
            callClient = client
            let deviceManager = try await client.getDeviceManager()
            deviceManager.delegate = self
            self.deviceManager = deviceManager
        } catch {
            throw CallCompositeInternalError.deviceManagerFailed(error)
        }
    }

    private func setupCallAgent() async throws {
        guard callAgent == nil else {
            logger.debug("Reusing call agent")
            return
        }

        let options = CallAgentOptions()
        if let displayName = callConfiguration.displayName {
            options.displayName = displayName
        }
        do {
            let callAgent = try await callClient?.createCallAgent(
                userCredential: callConfiguration.credential,
                options: options
            )
            self.logger.debug("Call agent successfully created.")
            self.callAgent = callAgent
        } catch {
            logger.error("It was not possible to create a call agent.")
            throw error
        }
    }

    private func makeCallClient() -> CallClient {
        let clientOptions = CallClientOptions()
        let appendingTag = self.callConfiguration.diagnosticConfig.tags
        let diagnostics = clientOptions.diagnostics ?? CallDiagnosticsOptions()
        diagnostics.tags.append(contentsOf: appendingTag)
        clientOptions.diagnostics = diagnostics
        return CallClient(options: clientOptions)
    }

    private func startCallVideoStream(
        _ videoStream: AzureCommunicationCalling.LocalVideoStream
    ) async throws -> String {
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

    private func change(
        _ videoStream: AzureCommunicationCalling.LocalVideoStream, source: VideoDeviceInfo
    ) async throws {
        do {
            try await videoStream.switchSource(camera: source)
            logger.debug("Local video switched camera successfully")
        } catch {
            logger.error( "Local video failed to switch camera. \(error)")
            throw error
        }
    }

    private func setupCallRecordingAndTranscriptionFeature() {
        guard let call = call else {
            return
        }
        let recordingCallFeature = call.feature(Features.recording)
        let transcriptionCallFeature = call.feature(Features.transcription)
        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
            callingEventsHandler.assign(recordingCallFeature)
            callingEventsHandler.assign(transcriptionCallFeature)
        }
    }

    private func getLocalVideoStreamIdentifier() -> String? {
        guard localVideoStream != nil else {
            return nil
        }
        return "builtinCameraVideoStream"
    }
}

extension CallingSDKWrapper: DeviceManagerDelegate {
    func deviceManager(_ deviceManager: DeviceManager, didUpdateCameras args: VideoDevicesUpdatedEventArgs) {
        for newDevice in args.addedVideoDevices {
            newVideoDeviceAddedHandler?(newDevice)
        }
    }

    private func getVideoDeviceInfo(_ cameraFacing: CameraFacing) async -> VideoDeviceInfo {
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

    private func getValidLocalVideoStream() async -> AzureCommunicationCalling.LocalVideoStream {
        if let existingVideoStream = localVideoStream {
            return existingVideoStream
        }

        let videoDevice = await getVideoDeviceInfo(.front)
        let videoStream = AzureCommunicationCalling.LocalVideoStream(camera: videoDevice)
        localVideoStream = videoStream
        return videoStream
    }
}

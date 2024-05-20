//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

import Combine
import Foundation

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class CallingSDKWrapper: NSObject, CallingSDKWrapperProtocol {
    let callingEventsHandler: CallingSDKEventsHandling

    private let logger: Logger
    private let callConfiguration: CallConfiguration
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var localVideoStream: AzureCommunicationCalling.LocalVideoStream?
    private var newVideoDeviceAddedHandler: ((VideoDeviceInfo) -> Void)?
    private var callKitOptions: CallKitOptions?
    private var callKitRemoteInfo: CallKitRemoteInfo?
    private var callingSDKInitializer: CallingSDKInitializer

    init(logger: Logger,
         callingEventsHandler: CallingSDKEventsHandling,
         callConfiguration: CallConfiguration,
         callKitOptions: CallKitOptions?,
         callKitRemoteInfo: CallKitRemoteInfo?,
         callingSDKInitializer: CallingSDKInitializer) {
        self.logger = logger
        self.callingEventsHandler = callingEventsHandler
        self.callConfiguration = callConfiguration
        self.callKitOptions = callKitOptions
        self.callKitRemoteInfo = callKitRemoteInfo
        self.callingSDKInitializer = callingSDKInitializer
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
        try await joinCall(isCameraPreferred: isCameraPreferred, isAudioPreferred: isAudioPreferred)
    }

    func joinCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug( "Joining call")
        let joinCallOptions = JoinCallOptions()

        // to fix iOS 15 issue
        // by default on iOS 15 calling SDK incoming type is raw video
        // because of this on iOS 15 remote video start event is not received
        let incomingVideoOptions = IncomingVideoOptions()
        incomingVideoOptions.streamType = .remoteIncoming

        if isCameraPreferred,
           let localVideoStream = localVideoStream {
            let localVideoStreamArray = [localVideoStream]

            let videoOptions = OutgoingVideoOptions()
            videoOptions.streams = localVideoStreamArray
            joinCallOptions.outgoingVideoOptions = videoOptions
        }

        joinCallOptions.outgoingAudioOptions = OutgoingAudioOptions()
        joinCallOptions.outgoingAudioOptions?.muted = !isAudioPreferred
        joinCallOptions.incomingVideoOptions = incomingVideoOptions
        if let remoteInfo = callKitRemoteInfo {
            let callKitRemoteInfo = AzureCommunicationCalling.CallKitRemoteInfo()
                callKitRemoteInfo.displayName = remoteInfo.displayName
                callKitRemoteInfo.handle = remoteInfo.handle
                joinCallOptions.callKitRemoteInfo = callKitRemoteInfo
        }
        var joinLocator: JoinMeetingLocator
        if callConfiguration.compositeCallType == .groupCall,
           let groupId = callConfiguration.groupId {
            joinLocator = GroupCallLocator(groupId: groupId)
        } else if callConfiguration.compositeCallType == .teamsMeeting,
                  let meetingLink = callConfiguration.meetingLink {
            joinLocator = TeamsMeetingLinkLocator(
                meetingLink: meetingLink.trimmingCharacters(in: .whitespacesAndNewlines))
        } /* <ROOMS_SUPPORT> */ else if callConfiguration.compositeCallType == .roomsCall,
                  let roomId = callConfiguration.roomId {
            joinLocator = RoomCallLocator(roomId: roomId.trimmingCharacters(in: .whitespacesAndNewlines))
        } /* </ROOMS_SUPPORT> */ else {
            logger.error("Invalid groupID / meeting link")
            throw CallCompositeInternalError.callJoinFailed
        }

        do {
            let callAgent = try await callingSDKInitializer.setupCallAgent()
            let joinedCall = try await callAgent.join(with: joinLocator, joinCallOptions: joinCallOptions)
            if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
                joinedCall.delegate = callingEventsHandler
            }
            call = joinedCall
            setupFeatures()
        } catch {
            logger.error( "Join call failed")
            throw CallCompositeInternalError.callJoinFailed
        }
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
            mediaStreamType: videoStream.sourceType.asCompositeMediaStreamType,
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
        guard !call.isOutgoingAudioMuted else {
            logger.warning("muteOutgoingAudio is skipped as outgoing audio already muted")
            return
        }

        do {
            try await call.muteOutgoingAudio()
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
        guard call.isOutgoingAudioMuted else {
            logger.warning("unmuteOutgoingAudio is skipped as outgoing audio already muted")
            return
        }

        do {
            try await call.unmuteOutgoingAudio()
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
    func getLogFiles() -> [URL] {
        return callingSDKInitializer.setupCallClient().debugInfo.supportFiles
    }

    func admitAllLobbyParticipants() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.callLobby.admitAll()
            logger.debug("Admit All participants successful")
        } catch {
            logger.error("ERROR: It was not possible to admit all lobby participants. \(error)")
            throw error
        }
    }

    func admitLobbyParticipant(_ participantId: String) async throws {
        guard let call = call else {
            return
        }

        let identifier = createCommunicationIdentifier(fromRawId: participantId)

        do {
            try await call.callLobby.admit(identifiers: [identifier])
            logger.debug("Admit participants successful")
        } catch {
            logger.error("ERROR: It was not possible to admit lobby participants. \(error)")
            throw error
        }
    }

    func declineLobbyParticipant(_ participantId: String) async throws {
        guard let call = call else {
            return
        }

        let identifier = createCommunicationIdentifier(fromRawId: participantId)

        do {
            try await call.callLobby.reject(identifier: identifier)
            logger.debug("Reject lobby participants successful")
        } catch {
            logger.error("ERROR: It was not possible to reject lobby participants. \(error)")
            throw error
        }
    }
}

extension CallingSDKWrapper {
    private func setupCallClientAndDeviceManager() async throws {
        do {
            let deviceManager = try await callingSDKInitializer.setupCallClient().getDeviceManager()
            deviceManager.delegate = self
            self.deviceManager = deviceManager
        } catch {
            throw CallCompositeInternalError.deviceManagerFailed(error)
        }
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

    private func setupFeatures() {
        guard let call = call else {
            return
        }
        let recordingCallFeature = call.feature(Features.recording)
        let transcriptionCallFeature = call.feature(Features.transcription)
        let dominantSpeakersFeature = call.feature(Features.dominantSpeakers)
        let localUserDiagnosticsFeature = call.feature(Features.localUserDiagnostics)
        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
            callingEventsHandler.assign(recordingCallFeature)
            callingEventsHandler.assign(transcriptionCallFeature)
            callingEventsHandler.assign(dominantSpeakersFeature)
            callingEventsHandler.assign(localUserDiagnosticsFeature)
        }
    }

    private func getLocalVideoStreamIdentifier() -> String? {
        guard localVideoStream != nil else {
            return nil
        }
        return "builtinCameraVideoStream"
    }
}
// swiftlint:enable type_body_length

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

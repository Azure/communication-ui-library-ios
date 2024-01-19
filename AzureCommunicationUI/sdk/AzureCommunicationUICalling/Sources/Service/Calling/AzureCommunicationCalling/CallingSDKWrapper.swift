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
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var localVideoStream: AzureCommunicationCalling.LocalVideoStream?
    private var callingSDKInitialization: CallingSDKInitialization?

    private var newVideoDeviceAddedHandler: ((VideoDeviceInfo) -> Void)?

    init(logger: Logger,
         callingEventsHandler: CallingSDKEventsHandling,
         callConfiguration: CallConfiguration,
         callingSDKInitialization: CallingSDKInitialization) {
        self.logger = logger
        self.callingEventsHandler = callingEventsHandler
        self.callConfiguration = callConfiguration
        self.callingSDKInitialization = callingSDKInitialization
        super.init()
    }

    func cleanup() {
        localVideoStream = nil
        deviceManager = nil
        call = nil
        callAgent = nil
        callClient = nil
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    func setupCall() async throws {
        callingSDKInitialization?.setupCallClient(tags: self.callConfiguration.diagnosticConfig.tags)
        callClient = callingSDKInitialization?.callClient!
        try await setupDeviceManager()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug("Reset Subjects in callingEventsHandler")
        if let callingEventsHandler = self.callingEventsHandler
            as? CallingSDKEventsHandler {
            callingEventsHandler.setupProperties()
        }
        logger.debug( "Starting call")
        do {
            if self.callConfiguration.credential != nil {
                try await callingSDKInitialization?.setupCallAgent(
                    tags: self.callConfiguration.diagnosticConfig.tags,
                    credential: self.callConfiguration.credential!,
                    callKitOptions: self.callConfiguration.callKitOptions,
                    displayName: self.callConfiguration.displayName)
            }
            callAgent = callingSDKInitialization?.callAgent
        } catch {
            throw CallCompositeInternalError.callJoinFailed
        }
        try await joinCall(isCameraPreferred: isCameraPreferred, isAudioPreferred: isAudioPreferred)
    }

    func joinCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug( "Joining call")
        let joinCallOptions = JoinCallOptions()
        let startCallOptions = StartCallOptions()

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
            startCallOptions.outgoingVideoOptions = videoOptions
        }
        if let callKitOptions = self.callConfiguration.callKitOptions,
            let remoteInfo = callKitOptions.remoteInfo {
                let callKitRemoteInfo = CallKitRemoteInfo()
                callKitRemoteInfo.displayName = remoteInfo.displayName
                callKitRemoteInfo.handle = remoteInfo.cxHandle
                joinCallOptions.callKitRemoteInfo = callKitRemoteInfo
                startCallOptions.callKitRemoteInfo = callKitRemoteInfo
        }
        joinCallOptions.outgoingAudioOptions = OutgoingAudioOptions()
        joinCallOptions.outgoingAudioOptions?.muted = !isAudioPreferred
        joinCallOptions.incomingVideoOptions = incomingVideoOptions
        startCallOptions.outgoingAudioOptions = OutgoingAudioOptions()
        startCallOptions.outgoingAudioOptions?.muted = !isAudioPreferred
        startCallOptions.incomingVideoOptions = incomingVideoOptions
        var joinLocator: JoinMeetingLocator?
        var participants: [CommunicationIdentifier] = []
        var call: Call?
        if callConfiguration.compositeCallType == .groupCall,
           let groupId = callConfiguration.groupId {
            joinLocator = GroupCallLocator(groupId: groupId)
        } else if callConfiguration.compositeCallType == .teamsMeeting,
                  let meetingLink = callConfiguration.meetingLink {
            joinLocator = TeamsMeetingLinkLocator(meetingLink: meetingLink)
        } else if callConfiguration.compositeCallType == .oneToNCallOutgoing,
        let callParticipants = callConfiguration.participants {
            participants = callParticipants.map { identifier in
                createCommunicationIdentifier(fromRawId: identifier)
            }
        } else if callConfiguration.compositeCallType == .oneToNCallIncoming {
            call = callAgent?.calls.first
        } else if callConfiguration.compositeCallType == .roomsCall,
                  let roomId = callConfiguration.roomId {
            joinLocator = RoomCallLocator(roomId: roomId)
        } else {
           logger.error("Invalid call")
           throw CallCompositeInternalError.callJoinFailed
        }
        if let joinLocatorForGroupCall = joinLocator {
            try await self.joinCallForGroupCall(joinLocator: joinLocatorForGroupCall, joinCallOptions: joinCallOptions)
        } else if callConfiguration.compositeCallType == .oneToNCallOutgoing {
            try await self.startCall(participants: participants, startCallOptions: startCallOptions)
        } else if callConfiguration.compositeCallType == .oneToNCallIncoming {
            let joinedCall = call
            guard let joinedCall = joinedCall else {
                logger.error( "incoming Join call failed")
                throw CallCompositeInternalError.callJoinFailed
            }
            if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
                joinedCall.delegate = callingEventsHandler
            }
            self.call = joinedCall
            setupFeatures()
        }
    }

    private func startCall(participants: [CommunicationIdentifier], startCallOptions: StartCallOptions) async throws {
        let joinedCall = try await callAgent?.startCall(participants: participants, options: startCallOptions)
        guard let joinedCall = joinedCall else { logger.error( "Join call failed")
            throw CallCompositeInternalError.callJoinFailed
        }

        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
            joinedCall.delegate = callingEventsHandler
        }
        self.call = joinedCall
        self.setupFeatures()
    }

    private func joinCallForGroupCall(joinLocator: JoinMeetingLocator, joinCallOptions: JoinCallOptions) async throws {
        let joinedCall = try await callAgent?.join(with: joinLocator, joinCallOptions: joinCallOptions)
        guard let joinedCall = joinedCall else {
            logger.error( "Join call failed")
            throw CallCompositeInternalError.callJoinFailed
        }

        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
            joinedCall.delegate = callingEventsHandler
        }
        call = joinedCall
        setupFeatures()
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
    private func setupDeviceManager() async throws {
        do {
            let deviceManager = try await callingSDKInitialization?.callClient?.getDeviceManager()
            deviceManager?.delegate = self
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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class CallingSDKWrapperInTest: NSObject, CallingSDKWrapperProtocol {
    let callingEventsHandler: CallingSDKEventsHandling

    private let logger: LoggerMocking
    private let callConfigurationMocking: CallConfigurationMocking
    private var callClientMocking: CallClientMocking?
    private var callAgentMocking: CallAgentMocking?
    private var callMocking: CallMocking?
    private var deviceManagerMocking: DeviceManagerMocking?
    private var localVideoStream: LocalVideoStreamMocking?

    private var newVideoDeviceAddedHandler: ((VideoDeviceInfoMocking) -> Void)?

    public override init() {
        logger = LoggerMocking()
        callingEventsHandler = CallingSDKEventsHandlerMocking(logger: logger)
        callConfigurationMocking = CallConfigurationMocking()
        super.init()
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    public func setupCall() async throws {
        try await setupCallClientAndDeviceManager()
    }

    public func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug("Reset Subjects in callingEventsHandler")
        if let callingEventsHandler = self.callingEventsHandler
            as? CallingSDKEventsHandlerMocking {
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

    public func joinCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug( "Joining call")

        guard let callAgent = callAgentMocking else {
            logger.error( "callAgent is nil")
            throw CallCompositeInternalError.callJoinFailed
        }
        let joinedCall = callAgent.join()
        guard let joinedCall = joinedCall else {
            logger.error( "Join call failed")
            throw CallCompositeInternalError.callJoinFailed
        }

        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            joinedCall.delegate = callingEventsHandler
            if callConfigurationMocking.compositeCallType == .groupCall {
                callingEventsHandler.joinCall()
            } else if callConfigurationMocking.compositeCallType == .teamsMeeting {
                callingEventsHandler.joinLobby()
            } else {
                logger.error("Invalid groupID / meeting link")
                throw CallCompositeInternalError.callJoinFailed
            }
        }

        callMocking = joinedCall
    }

    public func endCall() async throws {
        guard callMocking != nil else {
            throw CallCompositeInternalError.callEndFailed
        }
        logger.debug("Call ended successfully")
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.endCall()
        }
    }

    public func getRemoteParticipant<ParticipantType, StreamType>(_ identifier: String)
    -> CompositeRemoteParticipant<ParticipantType, StreamType>? {
        return nil
        // todo: will work on this in the next task
//        guard let remote = findParticipant(identifier: identifier) else {
//            return nil
//        }
//
//        let remoteParticipant = AzureCommunicationCalling.RemoteParticipant
//            .toCompositeRemoteParticipant(acsRemoteParticipant: remote)
//        guard let castValue = remoteParticipant as? CompositeRemoteParticipant<ParticipantType, StreamType> else {
//            return nil
//        }
//        return castValue
    }

    public func communicationIdForParticipant(identifier: String) -> CommunicationIdentifier? {
        return nil
//        findParticipant(identifier: identifier)?.identifier
    }

    private func findParticipant(identifier: String) -> AzureCommunicationCalling.RemoteParticipant? {
        return nil
//        call?.remoteParticipants.first(where: { $0.identifier.stringValue == identifier })
    }

    public func getLocalVideoStream<LocalVideoStreamType>(_ identifier: String)
    -> CompositeLocalVideoStream<LocalVideoStreamType>? {
        return nil
        // todo: will work on this in the next task
//        guard getLocalVideoStreamIdentifier() == identifier else {
//            return nil
//        }
//        guard let videoStream = localVideoStream,
//              let castVideoStream = videoStream as? LocalVideoStreamType else {
//            return nil
//        }
//        guard videoStream is LocalVideoStreamType else {
//            return nil
//        }
//        return CompositeLocalVideoStream(
//            mediaStreamType: videoStream.mediaStreamType.asCompositeMediaStreamType,
//            wrappedObject: castVideoStream
//        )
    }

    public func startCallLocalVideoStream() async throws -> String {
        return ""
        // todo: will work on this in the next task
//        let stream = await getValidLocalVideoStream()
//        return try await startCallVideoStream(stream)
    }

    public func stopLocalVideoStream() async throws {
        // todo: will work on this in the next task
//        guard let call = self.callMocking,
//              let videoStream = self.localVideoStream else {
//            logger.debug("Local video stopped successfully without call")
//            return
//        }
//        do {
//            try await call.stopVideo(stream: videoStream)
//            logger.debug("Local video stopped successfully")
//        } catch {
//            logger.error( "Local video failed to stop. \(error)")
//            throw error
//        }
    }

    public func switchCamera() async throws -> CameraDevice {
        return .front
        // todo: will work on this in the next task
//        guard let videoStream = localVideoStream else {
//            let error = CallCompositeInternalError.cameraSwitchFailed
//            logger.error("\(error)")
//            throw error
//        }
//        let currentCamera = videoStream.source
//        let flippedFacing: CameraFacing = currentCamera.cameraFacing == .front ? .back : .front
//
//        let deviceInfo = await getVideoDeviceInfo(flippedFacing)
//        try await change(videoStream, source: deviceInfo)
//        return flippedFacing.toCameraDevice()
    }

    public func startPreviewVideoStream() async throws -> String {
        return ""
        // todo: will work on this in the next task
//        _ = await getValidLocalVideoStream()
//        return getLocalVideoStreamIdentifier() ?? ""
    }

    public func muteLocalMic() async throws {
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.muteLocalMic()
        }
    }

    public func unmuteLocalMic() async throws {
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.unmuteLocalMic()
        }
    }

    public func holdCall() async throws {
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.holdCall()
        }
    }

    public func resumeCall() async throws {
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.resumeCall()
        }
    }
}

extension CallingSDKWrapperInTest {
    private func setupCallClientAndDeviceManager() async throws {
        let client = makeCallClientMocking()
        callClientMocking = client
        let deviceManager = client.getDeviceManagerMocking()
        deviceManager.delegate = self
        self.deviceManagerMocking = deviceManager
    }

    private func setupCallAgent() async throws {
        guard callAgentMocking == nil else {
            logger.debug("Reusing call agent")
            return
        }

        let options = CallAgentOptions()
        if let displayName = callConfigurationMocking.displayName {
            options.displayName = displayName
        }
        do {
            let callAgentMocking = try await callClientMocking?.createCallAgentMocking()
            self.logger.debug("Call agent successfully created.")
            self.callAgentMocking = callAgentMocking
        } catch {
            logger.error("It was not possible to create a call agent.")
            throw error
        }
    }

    private func makeCallClientMocking() -> CallClientMocking {
        let clientOptionsMocking = CallClientOptionsMocking()
        let appendingTag = self.callConfigurationMocking.diagnosticConfig.tags
        let diagnostics = clientOptionsMocking.diagnostics ?? CallDiagnosticsOptionsMocking()
        diagnostics.tags.append(contentsOf: appendingTag)
        clientOptionsMocking.diagnostics = diagnostics
        return CallClientMocking(options: clientOptionsMocking)
    }

    private func startCallVideoStream(
        _ videoStream: AzureCommunicationCalling.LocalVideoStream
    ) async throws -> String {
        return ""

        // todo: will work on this in the next task
//        guard let call = self.callMocking else {
//            let error = CallCompositeInternalError.cameraOnFailed
//            self.logger.error( "Start call video stream failed")
//            throw error
//        }
//        do {
//            let localVideoStreamId = getLocalVideoStreamIdentifier() ?? ""
//            try await call.startVideo(stream: videoStream)
//            logger.debug("Local video started successfully")
//            return localVideoStreamId
//        } catch {
//            logger.error( "Local video failed to start. \(error)")
//            throw error
//        }
    }

    private func change(_ videoStream: AzureCommunicationCalling.LocalVideoStream,
                        source: VideoDeviceInfoMocking) async throws {
        // todo: will work on this in the next task
//        do {
//            try await videoStream.switchSource(camera: source)
//            logger.debug("Local video switched camera successfully")
//        } catch {
//            logger.error( "Local video failed to switch camera. \(error)")
//            throw error
//        }
    }

    private func getLocalVideoStreamIdentifier() -> String? {
        // todo: will work on this in the next task
        guard localVideoStream != nil else {
            return nil
        }
        return "builtinCameraVideoStream"
    }
}

extension CallingSDKWrapperInTest: DeviceManagerDelegate {
    public func deviceManager(_ deviceManager: DeviceManager,
                              didUpdateCameras args: VideoDevicesUpdatedEventArgs) {
    }

    private func getVideoDeviceInfo(_ cameraFacing: CameraFacing) async -> VideoDeviceInfoMocking {
         return VideoDeviceInfoMocking(cameraFacing: .front)
    }

    private func getValidLocalVideoStream() async -> LocalVideoStreamMocking {
        return LocalVideoStreamMocking()
    }
}

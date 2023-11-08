//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling
#if DEBUG
@testable import AzureCommunicationUICalling

class UITestCallingSDKWrapper: NSObject, CallingSDKWrapperProtocol {
    let callingEventsHandler: CallingSDKEventsHandling

    private let logger: Logger
    private let callConfigurationMocking: CallConfigurationMocking
    private var callClientMocking: CallClientMocking?
    private var callAgentMocking: CallAgentMocking?
    private var callMocking: CallMocking?

    private var newVideoDeviceAddedHandler: ((VideoDeviceInfoMocking) -> Void)?

    private var mediaDiagnostics: [MediaCallDiagnostic] = [
        .speakingWhileMicrophoneIsMuted,
        .cameraStartFailed,
        .cameraStartTimedOut,
        .noSpeakerDevicesAvailable,
        .noMicrophoneDevicesAvailable,
        .microphoneNotFunctioning,
        .speakerNotFunctioning,
        .speakerMuted
    ]

    private var currentMediaDiagnostic: Int = 0
    private var currentNetworkDiagnostic: Int = 0

    public override init() {
        logger = DefaultLogger()
        callingEventsHandler = CallingSDKEventsHandlerMocking(logger: logger)
        callConfigurationMocking = CallConfigurationMocking()
        super.init()
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    func setupCall() async throws {
        try await setupDeviceManager()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
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

    func joinCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
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

    func endCall() async throws {
        guard callMocking != nil else {
            throw CallCompositeInternalError.callEndFailed
            logger.debug("EndCall() has failed; callMocking is nil")
        }
        logger.debug("Call ended successfully")
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.endCall()
            callMocking = nil
        }
    }

    func getRemoteParticipant<ParticipantType, StreamType>(_ identifier: String)
    -> CompositeRemoteParticipant<ParticipantType, StreamType>? {
        return nil
    }

    func getLocalVideoStream<LocalVideoStreamType>(_ identifier: String)
    -> CompositeLocalVideoStream<LocalVideoStreamType>? {
        return nil
    }

    func startCallLocalVideoStream() async throws -> String {
        return ""
    }

    func stopLocalVideoStream() async throws {
    }

    func switchCamera() async throws -> CameraDevice {
        return .front
    }

    func startPreviewVideoStream() async throws -> String {
        return ""
    }

    func muteLocalMic() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.muteLocalMic()
        }
    }

    func unmuteLocalMic() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.unmuteLocalMic()
        }
    }

    func holdCall() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.holdCall()
        }
    }

    func resumeCall() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.resumeCall()
        }
    }

    func transcriptionOn() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.transcriptionOn()
        }
    }

    func transcriptionOff() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.transcriptionOff()
        }
    }

    func recordingOn() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.recordingOn()
        }
    }

    func recordingOff() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.recordingOff()
        }
    }

    func addParticipant() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.addParticipant()
        }
    }

    func removeParticipant() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.removeParticipant()
        }
    }

    func unmuteParticipant() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.unmuteParticipant()
        }
    }

    func holdParticipant() async throws {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.holdParticipant()
        }
    }

    func emitMediaCallDiagnosticBadState() {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.emitMediaDiagnostic(mediaDiagnostics[currentMediaDiagnostic], value: true)
        }
    }

    func emitMediaCallDiagnosticGoodState() {
        guard callMocking != nil else {
            return
        }
        if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
            handler.emitMediaDiagnostic(mediaDiagnostics[currentMediaDiagnostic], value: false)
        }
    }

    func changeCurrentMediaDiagnostic() {
        if currentMediaDiagnostic == mediaDiagnostics.count - 1 {
            currentMediaDiagnostic = 0
        } else {
            currentMediaDiagnostic += 1
        }
    }

    func emitNetworkCallDiagnosticBadState() {
        guard callMocking != nil else {
            return
        }

        if currentNetworkDiagnostic <= 1 {
            if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
                handler.emitNetworkDiagnostic(
                    NetworkCallDiagnostic.allCases[currentNetworkDiagnostic], value: true)
            }
        } else {
            if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
                handler.emitNetworkQualityDiagnostic(
                    NetworkQualityCallDiagnostic.allCases[currentNetworkDiagnostic - 2], value: .bad)
            }
        }
    }

    func emitNetworkCallDiagnosticGoodState() {
        guard callMocking != nil else {
            return
        }

        if currentNetworkDiagnostic <= 1 {
            if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
                handler.emitNetworkDiagnostic(
                    NetworkCallDiagnostic.allCases[currentNetworkDiagnostic], value: false)
            }
        } else {
            if let handler = self.callingEventsHandler as? CallingSDKEventsHandlerMocking {
                handler.emitNetworkQualityDiagnostic(
                    NetworkQualityCallDiagnostic.allCases[currentNetworkDiagnostic - 2], value: .good)
            }
        }
    }

    func changeCurrentNetworkDiagnostic() {
        let count = NetworkCallDiagnostic.allCases.count + NetworkQualityCallDiagnostic.allCases.count
        if currentNetworkDiagnostic == count - 1 {
            currentNetworkDiagnostic = 0
        } else {
            currentNetworkDiagnostic += 1
        }
    }

    func handlePushNotification(remoteOptions: RemoteOptions) {
    }
}

extension UITestCallingSDKWrapper {
    private func setupDeviceManager() async throws {
        let client = makeCallClientMocking()
        callClientMocking = client
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
        return CallClientMocking(options: clientOptionsMocking)
    }
}
#endif

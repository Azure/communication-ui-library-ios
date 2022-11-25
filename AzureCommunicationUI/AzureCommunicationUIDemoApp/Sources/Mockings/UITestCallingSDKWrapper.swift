//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class UITestCallingSDKWrapper: NSObject, CallingSDKWrapperProtocol {
    let callingEventsHandler: CallingSDKEventsHandling

    private let logger: Logger
    private let callConfigurationMocking: CallConfigurationMocking
    private var callClientMocking: CallClientMocking?
    private var callAgentMocking: CallAgentMocking?
    private var callMocking: CallMocking?

    private var newVideoDeviceAddedHandler: ((VideoDeviceInfoMocking) -> Void)?

    public override init() {
        logger = DefaultLogger()
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
    }

    public func communicationIdForParticipant(identifier: String) -> CommunicationIdentifier? {
        return nil
    }

    public func getLocalVideoStream<LocalVideoStreamType>(_ identifier: String)
    -> CompositeLocalVideoStream<LocalVideoStreamType>? {
        return nil
    }

    public func startCallLocalVideoStream() async throws -> String {
        return ""
    }

    public func stopLocalVideoStream() async throws {
    }

    public func switchCamera() async throws -> CameraDevice {
        return .front
    }

    public func startPreviewVideoStream() async throws -> String {
        return ""
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

extension UITestCallingSDKWrapper {
    private func setupCallClientAndDeviceManager() async throws {
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

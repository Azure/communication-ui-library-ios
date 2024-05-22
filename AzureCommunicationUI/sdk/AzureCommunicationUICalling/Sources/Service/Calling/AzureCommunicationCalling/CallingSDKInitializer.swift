//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation

internal class CallingSDKInitializer: NSObject {
    // native calling SDK keeps single reference of call agent
    // this is to ensure that we don't create multiple call agents
    // destroying call agent is time consuming and we don't want to do it
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var incomingCall: AzureCommunicationCalling.IncomingCall?
    private var displayName: String?
    private var callKitOptions: AzureCommunicationUICalling.CallKitOptions?
    private var disableInternalPushForIncomingCall = false
    private var tags: [String]
    private var credential: CommunicationTokenCredential
    private var logger: Logger
    private var events: CallComposite.Events
    private var onCallAdded: (String) -> Void

    init(tags: [String],
         credential: CommunicationTokenCredential,
         callKitOptions: CallKitOptions?,
         displayName: String? = nil,
         disableInternalPushForIncomingCall: Bool,
         logger: Logger,
         events: CallComposite.Events,
         onCallAdded: @escaping (String) -> Void) {
        self.logger = logger
        self.tags = tags
        self.credential = credential
        self.callKitOptions = callKitOptions
        self.displayName = displayName
        self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
        self.events = events
        self.onCallAdded = onCallAdded
    }

    func getIncomingCall() -> AzureCommunicationCalling.IncomingCall? {
        return incomingCall
    }

    func setupCallClient() -> CallClient {
        if self.callClient == nil {
            self.callClient = makeCallClient()
        }
        return self.callClient!
    }

    func setupCallAgent() async throws -> CallAgent {
        if let existingCallAgent = self.callAgent {
                logger.debug("Reusing call agent")
                return existingCallAgent
        }
        let callClient = setupCallClient()
        let options = CallAgentOptions()
        options.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
        if let providerConfig = callKitOptions?.providerConfig {
            let sdkCallKitOptions = AzureCommunicationCalling.CallKitOptions(with: providerConfig)
            sdkCallKitOptions.isCallHoldSupported = callKitOptions!.isCallHoldSupported
            sdkCallKitOptions.configureAudioSession = callKitOptions!.configureAudioSession
            if let provideRemoteInfo = callKitOptions!.provideRemoteInfo {
                sdkCallKitOptions.provideRemoteInfo = { (callerInfo: AzureCommunicationCalling.CallerInfo)
                    -> AzureCommunicationCalling.CallKitRemoteInfo in
                    let info = provideRemoteInfo(
                        Caller(displayName: callerInfo.displayName,
                               identifier: callerInfo.identifier))
                    let callKitRemoteInfo = AzureCommunicationCalling.CallKitRemoteInfo()
                    callKitRemoteInfo.displayName = info.displayName
                    callKitRemoteInfo.handle = info.handle
                    return callKitRemoteInfo
                }
            }

            options.callKitOptions = sdkCallKitOptions
        }
        if let displayName = displayName {
            options.displayName = displayName
        }
        do {
            let callAgent = try await callClient.createCallAgent(
                userCredential: credential,
                options: options
            )
            self.callAgent = callAgent
            callAgent.delegate = self
            return callAgent
        } catch {
            logger.error("It was not possible to create a call agent.")
            throw error
        }
    }

    func registerPushNotification(deviceRegistrationToken: Data) async throws {
        do {
            let callAgent = try await setupCallAgent()
            try await callAgent.registerPushNotifications(
                deviceToken: deviceRegistrationToken)
        } catch {
            logger.error("Failed to registerPushNotification")
            throw error
        }
    }

    func unregisterPushNotifications() async throws {
        do {
            let callAgent = try await setupCallAgent()
            try await callAgent.unregisterPushNotification()
        } catch {
            logger.error("Failed to unregisterPushNotification")
            throw error
        }
    }

    static func reportIncomingCall(pushNotification: PushNotification,
                                   callKitOptions: CallKitOptions) async throws {
        do {
            let sdkCallKitOptions = AzureCommunicationCalling.CallKitOptions(with: callKitOptions.providerConfig)
            sdkCallKitOptions.isCallHoldSupported = callKitOptions.isCallHoldSupported
            sdkCallKitOptions.configureAudioSession = callKitOptions.configureAudioSession
            if let provideRemoteInfo = callKitOptions.provideRemoteInfo {
                sdkCallKitOptions.provideRemoteInfo = { (callerInfo: AzureCommunicationCalling.CallerInfo)
                    -> AzureCommunicationCalling.CallKitRemoteInfo in
                    let info = provideRemoteInfo(
                        Caller(displayName: callerInfo.displayName,
                               identifier: callerInfo.identifier))
                    let callKitRemoteInfo = AzureCommunicationCalling.CallKitRemoteInfo()
                    callKitRemoteInfo.displayName = info.displayName
                    callKitRemoteInfo.handle = info.handle
                    return callKitRemoteInfo
                }
            }
            let pushNotificationInfo = PushNotificationInfo.fromDictionary(pushNotification.data)
            try await CallClient.reportIncomingCall(
                with: pushNotificationInfo,
                callKitOptions: sdkCallKitOptions
            )
        } catch {}
    }

    func handlePushNotification(pushNotification: PushNotification) async throws {
        do {
            if let providerConfig = callKitOptions?.providerConfig {
                let sdkCallKitOptions = AzureCommunicationCalling.CallKitOptions(with: providerConfig)
                sdkCallKitOptions.isCallHoldSupported = ((callKitOptions?.isCallHoldSupported) != nil)
                sdkCallKitOptions.configureAudioSession = callKitOptions?.configureAudioSession
                if let provideRemoteInfo = callKitOptions?.provideRemoteInfo {
                    sdkCallKitOptions.provideRemoteInfo = { (callerInfo: AzureCommunicationCalling.CallerInfo)
                        -> AzureCommunicationCalling.CallKitRemoteInfo in
                        let info = provideRemoteInfo(
                            Caller(displayName: callerInfo.displayName,
                                   identifier: callerInfo.identifier))
                        let callKitRemoteInfo = AzureCommunicationCalling.CallKitRemoteInfo()
                        callKitRemoteInfo.displayName = info.displayName
                        callKitRemoteInfo.handle = info.handle
                        return callKitRemoteInfo
                    }
                }
                let pushNotificationInfo = PushNotificationInfo.fromDictionary(pushNotification.data)
                try await CallClient.reportIncomingCall(
                    with: pushNotificationInfo,
                    callKitOptions: sdkCallKitOptions
                )
            }
        } catch {}
        do {
            let pushNotificationInfo = PushNotificationInfo.fromDictionary(pushNotification.data)
            let callAgent = try await setupCallAgent()
            try await callAgent.handlePush(notification: pushNotificationInfo)
        } catch {
            logger.error("Failed to handlePush")
            throw error
        }
    }

    func reject(incomingCallId: String) async throws {
        if incomingCall == nil ||
            incomingCall?.id != incomingCallId {
            throw IncomingCallError.callIdNotFound
        }
        do {
            try await incomingCall?.reject()
        } catch {
            logger.error("Failed to handlePush")
            throw error
        }
    }

    func dispose() {
        self.callAgent?.delegate = nil
        self.callAgent?.dispose()
        self.callAgent = nil
        self.callClient = nil
    }

    private func makeCallClient() -> CallClient {
        let clientOptions = CallClientOptions()
        let appendingTag = tags
        let diagnostics = clientOptions.diagnostics ?? CallDiagnosticsOptions()
        diagnostics.tags.append(contentsOf: appendingTag)
        clientOptions.diagnostics = diagnostics
        return CallClient(options: clientOptions)
    }
}

extension CallingSDKInitializer: CallAgentDelegate {
    public func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        self.logger.debug("InderpalTest -> on calls update received")
        if !args.addedCalls.isEmpty {
            if let call = args.addedCalls.first {
                let callId = call.id
                self.logger.debug("InderpalTest -> on calls update received, notifying for \(callId)")
                self.onCallAdded(callId)
            }
        }
    }

    public func callAgent(_ callAgent: CallAgent,
                          didRecieveIncomingCall incomingCall: AzureCommunicationCalling.IncomingCall) {
        self.incomingCall = incomingCall
        incomingCall.delegate = self
        self.logger.debug("InderpalTest -> incomingCall received, notifying for \(incomingCall.id)")
        let incomingCallInfo = IncomingCall(
            callId: incomingCall.id,
            callerDisplayName: incomingCall.callerInfo.displayName,
            callerIdentifier: incomingCall.callerInfo.identifier)
        guard let onIncomingCallEventHandler = events.onIncomingCall else {
            return
        }
        onIncomingCallEventHandler(incomingCallInfo)
    }
}

extension CallingSDKInitializer: IncomingCallDelegate {
    func incomingCall(_ incomingCall: AzureCommunicationCalling.IncomingCall, didEnd args: PropertyChangedEventArgs) {
        guard let onIncomingCallCancelled = events.onIncomingCallCancelled,
              let callEndReason = incomingCall.callEndReason else {
            return
        }
        let callCancelled = IncomingCallCancelled(
            callId: incomingCall.id,
            code: Int(callEndReason.code),
            subCode: Int(callEndReason.subcode)
        )
        onIncomingCallCancelled(callCancelled)
    }
}

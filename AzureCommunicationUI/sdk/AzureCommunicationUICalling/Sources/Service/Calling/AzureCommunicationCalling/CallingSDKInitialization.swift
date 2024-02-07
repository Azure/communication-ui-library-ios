//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation

internal class CallingSDKInitialization: NSObject {
    // native calling SDK keeps single reference of call agent
    // this is to ensure that we don't create multiple call agents
    // destroying call agent is time consuming and we don't want to do it
    var callClient: CallClient?
    var callAgent: CallAgent?
    var callsUpdatedProtocol: CallsUpdatedProtocol?
    var onCallAdded: ((String) -> Void)?
    var displayName: String?
    var callCompositeCallKitOptions: CallCompositeCallKitOption?
    var disableInternalPush: Bool = false

    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    func setupCallClient(tags: [String]) {
        guard self.callClient == nil else {
            logger.debug("Reusing call client")
            return
        }
        let client = makeCallClient(tags: tags)
        self.callClient = client
    }

    func setupCallAgent(tags: [String],
                        credential: CommunicationTokenCredential,
                        callKitOptions: CallCompositeCallKitOption?,
                        displayName: String? = nil,
                        disableInternalPushForIncomingCall: Bool) async throws {
        guard self.callAgent == nil else {
            logger.debug("Reusing call agent")
            return
        }
        setupCallClient(tags: tags)
        let options = CallAgentOptions()
        options.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
        self.disableInternalPush = disableInternalPushForIncomingCall
        self.callCompositeCallKitOptions = callKitOptions
        if let callKitConfig = callKitOptions?.cxProvideConfig {
            let sdkCallKitOptions = CallKitOptions(with: callKitConfig)
            sdkCallKitOptions.isCallHoldSupported = callKitOptions!.isCallHoldSupported
            sdkCallKitOptions.configureAudioSession = callKitOptions!.configureAudioSession
            if let incomingRemoteInfoCallback = callKitOptions!.configureIncomingCallRemoteInfo {
                sdkCallKitOptions.provideRemoteInfo = { (callerInfo: CallerInfo) -> CallKitRemoteInfo in
                    let info = incomingRemoteInfoCallback(
                        CallCompositeCallerInfo(callerDisplayName: callerInfo.displayName,
                                                callerIdentifierRawId: callerInfo.identifier.rawId))
                    let callKitRemoteInfo = CallKitRemoteInfo()
                    callKitRemoteInfo.displayName = info.displayName
                    callKitRemoteInfo.handle = info.cxHandle
                    return callKitRemoteInfo
                }
            }

            options.callKitOptions = sdkCallKitOptions
        }
        if let displayName = displayName {
            options.displayName = displayName
        }
        self.displayName = displayName
        do {
            let callAgent = try await self.callClient?.createCallAgent(
                userCredential: credential,
                options: options
            )
            self.logger.debug("Call agent successfully created.")
            self.callAgent = callAgent
            self.callAgent?.delegate = self
        } catch {
            logger.error("It was not possible to create a call agent.")
            throw error
        }
    }

    func registerPushNotification(notificationOptions: CallCompositePushNotificationOptions,
                                  tags: [String]) async throws {
        do {
            try await setupCallAgent(tags: tags,
                                     credential: notificationOptions.credential,
                                     callKitOptions: notificationOptions.callKitOptions,
                                     displayName: notificationOptions.displayName,
                                     disableInternalPushForIncomingCall:
                                        notificationOptions.disableInternalPushForIncomingCall)
            try await self.callAgent?.registerPushNotifications(
                deviceToken: notificationOptions.deviceRegistrationToken)
            logger.debug("registerPushNotifications success")
        } catch {
            logger.error("Failed to registerPushNotification")
            throw error
        }
    }

    func handlePushNotification(tags: [String],
                                credential: CommunicationTokenCredential,
                                callKitOptions: CallCompositeCallKitOption?,
                                displayName: String? = nil,
                                callNotification: PushNotificationInfo,
                                disableInternalPushForIncomingCall: Bool) async throws {
        do {
            let callKitOptionsInternal = CallKitOptions(with: callKitOptions!.cxProvideConfig)
            callKitOptionsInternal.isCallHoldSupported = callKitOptions!.isCallHoldSupported
            callKitOptionsInternal.configureAudioSession = callKitOptions!.configureAudioSession
            if let incomingRemoteInfoCallback = callKitOptions!.configureIncomingCallRemoteInfo {
                callKitOptionsInternal.provideRemoteInfo = { (callerInfo: CallerInfo) -> CallKitRemoteInfo in
                    let info = incomingRemoteInfoCallback(
                        CallCompositeCallerInfo(callerDisplayName: callerInfo.displayName,
                                                callerIdentifierRawId: callerInfo.identifier.rawId))
                    let callKitRemoteInfo = CallKitRemoteInfo()
                    callKitRemoteInfo.displayName = info.displayName
                    callKitRemoteInfo.handle = info.cxHandle
                    return callKitRemoteInfo
                }
            }
            try await CallClient.reportIncomingCall(
                with: callNotification,
                callKitOptions: callKitOptionsInternal
            )
        } catch {}
        do {
            self.logger.debug("setupCallAgent handlePushNotification")
            try await setupCallAgent(tags: tags,
                                     credential: credential,
                                     callKitOptions: callKitOptions,
                                     displayName: displayName,
                                     disableInternalPushForIncomingCall: disableInternalPushForIncomingCall)
            try await self.callAgent?.handlePush(notification: callNotification)
            self.logger.debug("handlePush success")
        } catch {
            logger.error("Failed to handlePush")
            throw error
        }
    }

    func dispose() {
        self.callAgent?.delegate = nil
        self.callAgent?.dispose()
        self.callsUpdatedProtocol = nil
        self.callAgent = nil
        self.callClient = nil
    }

    private func makeCallClient(tags: [String]) -> CallClient {
        let clientOptions = CallClientOptions()
        let appendingTag = tags
        let diagnostics = clientOptions.diagnostics ?? CallDiagnosticsOptions()
        diagnostics.tags.append(contentsOf: appendingTag)
        clientOptions.diagnostics = diagnostics
        return CallClient(options: clientOptions)
    }
}

extension CallingSDKInitialization: CallAgentDelegate {
    public func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        self.logger.debug("on calls update received")
        if !args.addedCalls.isEmpty {
            let call = args.addedCalls.first
            let callId = (call?.id ?? "") as String
            self.logger.debug("on calls update received, notifying for \(callId)")
            self.onCallAdded?(callId)
        }
    }

    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        self.callsUpdatedProtocol?.onIncomingCall(incomingCall: incomingCall)
    }
}

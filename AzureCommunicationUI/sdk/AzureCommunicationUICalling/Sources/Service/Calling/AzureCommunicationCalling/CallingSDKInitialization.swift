//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

import Foundation

internal class CallingSDKInitialization {
    // native calling SDK keeps single reference of call agent
    // this is to ensure that we don't create multiple call agents
    // destroying call agent is time consuming and we don't want to do it
    var callClient: CallClient?
    var callAgent: CallAgent?
    var callsUpdatedProtocol: CallsUpdatedProtocol?
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
                        displayName: String? = nil) async throws {
        guard self.callAgent == nil else {
            logger.debug("Reusing call agent")
            return
        }
        setupCallClient(tags: tags)
        let options = CallAgentOptions()
        if let callKitConfig = callKitOptions?.cxProvideConfig {
            let callKitOptions = CallKitOptions(with: callKitConfig)
            callKitOptions.isCallHoldSupported = callKitOptions.isCallHoldSupported
            callKitOptions.configureAudioSession = callKitOptions.configureAudioSession
            options.callKitOptions = callKitOptions
        }
        if let displayName = displayName {
            options.displayName = displayName
        }
        do {
            let callAgent = try await self.callClient?.createCallAgent(
                userCredential: credential,
                options: options
            )
            self.logger.debug("Call agent successfully created.")
            self.callAgent = callAgent
            self.callAgent!.events.onIncomingCall = { [weak self] incomingCall in
                self?.logger.debug("Incoming call received." + incomingCall.id)
                self?.callsUpdatedProtocol?.onIncomingCall(incomingCall: incomingCall)
            }
            self.callAgent!.events.onCallsUpdated = { [weak self] calls in
                self?.logger.debug("Added call count \(calls.addedCalls.count).")
                self?.logger.debug("Removed call count \(calls.removedCalls.count).")
                self?.callsUpdatedProtocol?.onCallsUpdated()
            }
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
                                     displayName: notificationOptions.displayName)
            try await self.callAgent?.registerPushNotifications(
                deviceToken: notificationOptions.deviceRegistrationToken)
        } catch {
            logger.error("Failed to registerPushNotification")
            throw error
        }
    }

    func handlePushNotification(tags: [String],
                                credential: CommunicationTokenCredential,
                                callKitOptions: CallCompositeCallKitOption?,
                                displayName: String? = nil,
                                callNotification: PushNotificationInfo) async throws {
        do {
            try await setupCallAgent(tags: tags,
                                     credential: credential,
                                     callKitOptions: callKitOptions,
                                     displayName: displayName)
            try await self.callAgent?.handlePush(notification: callNotification)
        } catch {
            logger.error("Failed to handlePush")
            throw error
        }
    }

    func dispose() {
        self.callsUpdatedProtocol = nil
        self.callAgent?.dispose()
        self.callAgent = nil
        self.callClient?.dispose()
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

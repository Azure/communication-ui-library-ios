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
    static var callClient: CallClient?
    static var callAgent: CallAgent?
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    func setupCallClient(tags: [String]) {
        guard CallingSDKInitialization.callClient == nil else {
            logger.debug("Reusing call client")
            return
        }
        let client = makeCallClient(tags: tags)
        CallingSDKInitialization.callClient = client
    }

    func setupCallAgent(tags: [String],
                        credential: CommunicationTokenCredential,
                        callKitOptions: CallCompositeCallKitOption?,
                        displayName: String? = nil) async throws {
        guard CallingSDKInitialization.callAgent == nil else {
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
            let callAgent = try await CallingSDKInitialization.callClient?.createCallAgent(
                userCredential: credential,
                options: options
            )
            self.logger.debug("Call agent successfully created.")
            CallingSDKInitialization.callAgent = callAgent
        } catch {
            logger.error("It was not possible to create a call agent.")
            throw error
        }
    }

    func registerPushNotification(notificationOptions: PushNotificationOptions,
                                  tags: [String]) async throws {
        do {
            try await setupCallAgent(tags: tags,
                                     credential: notificationOptions.credential,
                                     callKitOptions: notificationOptions.callKitOptions,
                                     displayName: notificationOptions.displayName)
            try await CallingSDKInitialization.callAgent?.registerPushNotifications(
                deviceToken: notificationOptions.deviceRegistrationToken)
        } catch {
            logger.error("Failed to registerPushNotification")
            throw error
        }
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

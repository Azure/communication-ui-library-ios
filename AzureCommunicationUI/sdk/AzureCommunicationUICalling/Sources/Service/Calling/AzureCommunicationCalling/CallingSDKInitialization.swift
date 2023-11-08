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

    func setupCallAgent(callConfiguration: CallConfiguration) async throws {
        guard CallingSDKInitialization.callAgent == nil else {
            logger.debug("Reusing call agent")
            return
        }
        setupCallClient(tags: callConfiguration.diagnosticConfig.tags)
        let options = CallAgentOptions()
        if let callKitConfig = callConfiguration.callKitOptions?.cxProvideConfig {
            let callKitOptions = CallKitOptions(with: callKitConfig)
            callKitOptions.isCallHoldSupported = callConfiguration.callKitOptions?.isCallHoldSupported ?? true
            callKitOptions.configureAudioSession = callConfiguration.callKitOptions?.configureAudioSession
            options.callKitOptions = callKitOptions
        }
        if let displayName = callConfiguration.displayName {
            options.displayName = displayName
        }
        do {
            let callAgent = try await CallingSDKInitialization.callClient?.createCallAgent(
                userCredential: callConfiguration.credential,
                options: options
            )
            self.logger.debug("Call agent successfully created.")
            CallingSDKInitialization.callAgent = callAgent
        } catch {
            logger.error("It was not possible to create a call agent.")
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

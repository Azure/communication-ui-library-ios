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
    private var onCallAdded: ((String) -> Void)?
    private var displayName: String?
    private var callKitOptions: AzureCommunicationUICalling.CallKitOptions?
    private var disableInternalPushForIncomingCall = false
    private var tags: [String]
    private var credential: CommunicationTokenCredential
    private var logger: Logger

    init(tags: [String],
         credential: CommunicationTokenCredential,
         callKitOptions: CallKitOptions?,
         displayName: String? = nil,
         disableInternalPushForIncomingCall: Bool,
         logger: Logger) {
        self.logger = logger
        self.tags = tags
        self.credential = credential
        self.callKitOptions = callKitOptions
        self.displayName = displayName
        self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
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
        var callClient = setupCallClient()
        let options = CallAgentOptions()
        // options.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
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
            var callAgent = try await callClient.createCallAgent(
                userCredential: credential,
                options: options
            )
            self.callAgent = callAgent
            return callAgent
        } catch {
            logger.error("It was not possible to create a call agent.")
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

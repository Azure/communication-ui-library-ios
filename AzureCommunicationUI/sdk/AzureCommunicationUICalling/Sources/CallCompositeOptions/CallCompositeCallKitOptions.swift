//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit options for the call.
public struct CallCompositeCallKitOptions {
    /// CXProviderConfiguration for the call.
    public let providerConfig: CXProviderConfiguration

    /// Whether the call supports hold. Default is true.
    public let isCallHoldSupported: Bool

    /// CallKit remote participant.
    public let remoteParticipant: CallCompositeCallKitRemoteParticipant?

    /// Configure audio session will be called before placing or accepting
    /// incoming call and before resuming the call after it has been put on hold
    public let configureAudioSession: (() -> Error?)?

    /// CallKit remote participant callback for incoming call
    public let configureIncomingCallCaller: ((CallCompositeCaller)
                                          -> CallCompositeCallKitRemoteParticipant)?

    /// Create an instance of a CallCompositeCallKitOptions with options.
    /// - Parameters:
    ///   - providerConfig: CXProviderConfiguration for the call.
    ///   - isCallHoldSupported: Whether the call supports hold. Default is true.
    ///   - remoteParticipant: CallKit remote participant
    ///   - configureIncomingCallRemote: CallKit remote participant callback for incoming call
    ///   - configureAudioSession: Configure audio session will be called before placing or accepting
    ///     incoming call and before resuming the call after it has been put on hold
    public init(providerConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool = true,
                remoteParticipant: CallCompositeCallKitRemoteParticipant? = nil,
                configureIncomingCallCaller: ((CallCompositeCaller)
                                                  -> CallCompositeCallKitRemoteParticipant)? = nil,
                configureAudioSession: (() -> Error?)? = nil) {
        self.providerConfig = providerConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteParticipant = remoteParticipant
        self.configureAudioSession = configureAudioSession
        self.configureIncomingCallCaller = configureIncomingCallCaller
    }

    /// Create an instance of a CallCompositeCallKitOptions with default options.
    public init() {
        let providerConfig = CXProviderConfiguration()
        providerConfig.supportsVideo = true
        providerConfig.maximumCallGroups = 1
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.phoneNumber, .generic]
        self.providerConfig = providerConfig
        self.isCallHoldSupported = true
        self.remoteParticipant = nil
        self.configureAudioSession = nil
        self.configureIncomingCallCaller = nil
    }
}

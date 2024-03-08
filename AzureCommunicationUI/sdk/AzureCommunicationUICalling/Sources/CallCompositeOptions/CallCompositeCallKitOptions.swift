//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit options for the call.
public struct CallCompositeCallKitOptions {
    /// CXProviderConfiguration for the call.
    public let cxProviderConfig: CXProviderConfiguration

    /// Whether the call supports hold. Default is true.
    public let isCallHoldSupported: Bool

    /// CallKit remote participant info
    public let remoteInfo: CallCompositeCallKitRemoteInfo?

    /// Configure audio session will be called before placing or accepting
    /// incoming call and before resuming the call after it has been put on hold
    public let configureAudioSession: (() -> Error?)?

    /// CallKit remote participant info callback for incoming call
    public let configureIncomingCallRemoteInfo: ((CallCompositeCallerInfo)
                                          -> CallCompositeCallKitRemoteInfo)?

    /// Create an instance of a CallCompositeCallKitOptions with options.
    /// - Parameters:
    ///   - cxProviderConfig: CXProviderConfiguration for the call.
    ///   - isCallHoldSupported: Whether the call supports hold. Default is true.
    ///   - remoteInfo: CallKit remote participant info
    ///   - configureIncomingCallRemoteInfo: CallKit remote participant info callback for incoming call
    ///   - configureAudioSession: Configure audio session will be called before placing or accepting
    ///     incoming call and before resuming the call after it has been put on hold
    public init(cxProviderConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool = true,
                remoteInfo: CallCompositeCallKitRemoteInfo? = nil,
                configureIncomingCallRemoteInfo: ((CallCompositeCallerInfo)
                                                  -> CallCompositeCallKitRemoteInfo)? = nil,
                configureAudioSession: (() -> Error?)? = nil) {
        self.cxProviderConfig = cxProviderConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteInfo = remoteInfo
        self.configureAudioSession = configureAudioSession
        self.configureIncomingCallRemoteInfo = configureIncomingCallRemoteInfo
    }

    /// Create an instance of a CallCompositeCallKitOptions with default options.
    public init() {
        let providerConfig = CXProviderConfiguration()
        providerConfig.supportsVideo = true
        providerConfig.maximumCallGroups = 1
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.phoneNumber, .generic]
        self.cxProviderConfig = providerConfig
        self.isCallHoldSupported = true
        self.remoteInfo = nil
        self.configureAudioSession = nil
        self.configureIncomingCallRemoteInfo = nil
    }
}

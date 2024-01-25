//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit options for the call.
public struct CallCompositeCallKitOption {
    /// CXProviderConfiguration for the call.
    public let cxProvideConfig: CXProviderConfiguration

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

    public init(cxProvideConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool = true,
                remoteInfo: CallCompositeCallKitRemoteInfo? = nil,
                configureIncomingCallRemoteInfo: ((CallCompositeCallerInfo)
                                                  -> CallCompositeCallKitRemoteInfo)? = nil,
                configureAudioSession: (() -> Error?)? = nil) {
        self.cxProvideConfig = cxProvideConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteInfo = remoteInfo
        self.configureAudioSession = configureAudioSession
        self.configureIncomingCallRemoteInfo = configureIncomingCallRemoteInfo
    }

    public init() {
        self.cxProvideConfig = CallCompositeCallKitOption.getDefaultCXProviderConfiguration()
        self.isCallHoldSupported = true
        self.remoteInfo = nil
        self.configureAudioSession = nil
        self.configureIncomingCallRemoteInfo = nil
    }

    public static func getDefaultCXProviderConfiguration() -> CXProviderConfiguration {
        let providerConfig = CXProviderConfiguration()
        providerConfig.supportsVideo = true
        providerConfig.maximumCallGroups = 1
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.phoneNumber, .generic]
        return providerConfig
    }
}

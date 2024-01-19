//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit options for the call.
internal struct CallCompositeCallKitOption {
    /// CXProviderConfiguration for the call.
    let cxProvideConfig: CXProviderConfiguration

    /// Whether the call supports hold. Default is true.
    let isCallHoldSupported: Bool

    /// CallKit remote participant info
    let remoteInfo: CallCompositeCallKitRemoteInfo?

    /// Configure audio session will be called before placing or accepting 
    /// incoming call and before resuming the call after it has been put on hold
    let configureAudioSession: (() -> Error?)?

    public init(cxProvideConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool = true,
                remoteInfo: CallCompositeCallKitRemoteInfo? = nil,
                configureAudioSession: (() -> Error?)? = nil) {
        self.cxProvideConfig = cxProvideConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteInfo = remoteInfo
        self.configureAudioSession = configureAudioSession
    }

    public init() {
        self.cxProvideConfig = CallCompositeCallKitOption.getDefaultCXProviderConfiguration()
        self.isCallHoldSupported = true
        self.remoteInfo = nil
        self.configureAudioSession = nil
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

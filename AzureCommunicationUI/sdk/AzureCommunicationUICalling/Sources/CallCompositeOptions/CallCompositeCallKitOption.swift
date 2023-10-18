//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

public struct CallCompositeCallKitOption {
    let cxProvideConfig: CXProviderConfiguration
    let isCallHoldSupported: Bool
    let remoteInfo: CallCompositeCallKitRemoteInfo?

    public init(cxProvideConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool,
                remoteInfo: CallCompositeCallKitRemoteInfo?) {
        self.cxProvideConfig = cxProvideConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteInfo = remoteInfo
    }

    public init(cxProvideConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool) {
        self.cxProvideConfig = cxProvideConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteInfo = nil
    }

    public init(cxProvideConfig: CXProviderConfiguration) {
        self.cxProvideConfig = cxProvideConfig
        self.isCallHoldSupported = true
        self.remoteInfo = nil
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

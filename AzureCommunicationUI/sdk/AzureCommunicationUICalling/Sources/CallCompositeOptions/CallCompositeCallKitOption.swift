//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit options for the call.
public struct CallCompositeCallKitOption {
    /// CXProviderConfiguration for the call.
    let cxProvideConfig: CXProviderConfiguration

    /// Whether the call supports hold. Default is true.
    let isCallHoldSupported: Bool

    /// CallKit remote participant info for the call to display in call history.
    /// If nil, the history will display remote participant raw identifier.
    let remoteInfo: CallCompositeCallKitRemoteInfo?

    public init(cxProvideConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool = true,
                remoteInfo: CallCompositeCallKitRemoteInfo? = nil) {
        self.cxProvideConfig = cxProvideConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteInfo = remoteInfo
    }

    /// Get default CXProviderConfiguration for the call.
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

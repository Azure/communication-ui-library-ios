//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

public struct CallCompositeCallKitOption {
    let cxProvideConfig: CXProviderConfiguration
    let isCallHoldSupported: Bool
    let remoteInfoDisplayName: String?
    let remoteInfoCXHandle: CXHandle?

    public init(cxProvideConfig: CXProviderConfiguration,
                isCallHoldSupported: Bool,
                remoteInfoDisplayName: String,
                remoteInfoCXHandle: CXHandle?) {
        self.cxProvideConfig = cxProvideConfig
        self.isCallHoldSupported = isCallHoldSupported
        self.remoteInfoDisplayName = remoteInfoDisplayName
        self.remoteInfoCXHandle = remoteInfoCXHandle
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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUICalling
import CallKit

class CallCompositeHandler {
    static let shared = CallCompositeHandler()
    var callComposite: CallComposite?
    var deviceToken: Data?
    private init() { }

    func setupCallComposite(deviceToken: Data?) {
        guard let devToken = deviceToken else {
            return
        }
        self.deviceToken = devToken
        let callCompositeOptions = CallCompositeOptions(deviceToken: devToken)
        CallCompositeHandler.shared.callComposite = CallComposite(withOptions: callCompositeOptions)
    }
    func createProviderConfig() -> CXProviderConfiguration {
        let providerConfig = CXProviderConfiguration()
        providerConfig.supportsVideo = true
        providerConfig.maximumCallGroups = 1
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.phoneNumber, .generic]
        return providerConfig
    }
}

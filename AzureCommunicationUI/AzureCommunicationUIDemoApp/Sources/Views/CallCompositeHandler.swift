//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUICalling

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
}

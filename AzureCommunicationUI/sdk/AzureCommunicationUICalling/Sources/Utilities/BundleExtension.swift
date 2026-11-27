//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Bundle {
    /// The bundle that contains the AzureCommunicationUICalling resources (assets and localizations).
    static var azureCommunicationUICalling: Bundle {
#if SWIFT_PACKAGE
        return .module
#else
        return Bundle(for: CallComposite.self)
#endif
    }
}

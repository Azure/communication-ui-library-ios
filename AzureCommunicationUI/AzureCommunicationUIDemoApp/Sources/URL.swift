//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Intents

extension URL: StartCallConvertible {

    private struct Constants {
        static let URLScheme: String = "acsui"
    }

    var startCallHandle: String? { // Explicitly define the data type as String
        guard scheme == Constants.URLScheme else {
            return nil
        }

        return host
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum CallCompositeAvMode {
    case normal
    case audioOnly

    var rawValue: String {
        switch self {
        case .normal:
            return "normal"
        case .audioOnly:
            return "audioOnly"
        }
    }
}

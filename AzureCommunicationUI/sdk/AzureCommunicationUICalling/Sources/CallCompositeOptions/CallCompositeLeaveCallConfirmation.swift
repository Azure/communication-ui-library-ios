//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Enum defining options for leaving a call confirmation.
public enum CallCompositeLeaveCallConfirmation {
    /// Enables the leave call confirmation.
    case enable
    /// Disables the leave call confirmation.
    case disable

    /// Provides a `String` representation of the mode.
    /// - For `.enable`, returns "enable".
    /// - For `.disable`, returns "disable".
    var rawValue: String {
        switch self {
        case .enable:
            return "enable"
        case .disable:
            return "disable"
        }
    }
}

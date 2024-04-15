//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Enum defining options for leaving a call confirmation.
public enum LeaveCallConfirmationMode {
    /// Enables the leave call confirmation.
    case alwaysEnabled
    /// Disables the leave call confirmation.
    case alwaysDisabled

    /// Provides a `String` representation of the mode.
    /// - For `.always_enabled`, returns "always_enabled".
    /// - For `.always_disabled`, returns "always_disabled".
    var rawValue: String {
        switch self {
        case .alwaysEnabled:
            return "always_enabled"
        case .alwaysDisabled:
            return "always_disabled"
        }
    }
}

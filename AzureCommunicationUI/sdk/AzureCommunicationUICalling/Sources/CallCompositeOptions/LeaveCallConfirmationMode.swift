//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

/// Enum defining options for leaving a call confirmation.
public struct LeaveCallConfirmationMode: Equatable, RequestStringConvertible {
    internal enum  LeaveCallConfirmationModeKV {
        case alwaysEnabled
        case alwaysDisabled
        case unknown(String)

        var rawValue: String {
            switch self {
            case .alwaysEnabled:
                return "always_enabled"
            case .alwaysDisabled:
                return "always_disabled"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "always_enabled":
                self = .alwaysEnabled
            case "always_disabled":
                self = .alwaysDisabled
            default:
                self = .unknown(rawValue.lowercased())
            }
        }
    }

    private let value: LeaveCallConfirmationModeKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = LeaveCallConfirmationModeKV(rawValue: rawValue)
    }

    public static func == (lhs: LeaveCallConfirmationMode, rhs: LeaveCallConfirmationMode) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    /// Enables the leave call confirmation.
    public static let alwaysEnabled: LeaveCallConfirmationMode = .init(rawValue: "always_enabled")

    /// Disables the leave call confirmation.
    public static let alwaysDisabled: LeaveCallConfirmationMode = .init(rawValue: "always_disabled")
}

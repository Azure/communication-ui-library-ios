//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

/// Enum defining options for notification about capabilities change.
public struct CapabilitiesChangedNotificationMode: Equatable, RequestStringConvertible {
    internal enum  CapabilitiesChangedNotificationModeKV {
        case alwaysDisplay
        case neverDisplay
        case unknown(String)

        var rawValue: String {
            switch self {
            case .alwaysDisplay:
                return "always_display"
            case .neverDisplay:
                return "never_display"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "always_display":
                self = .alwaysDisplay
            case "never_display":
                self = .neverDisplay
            default:
                self = .unknown(rawValue.lowercased())
            }
        }
    }

    private let value: CapabilitiesChangedNotificationModeKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = CapabilitiesChangedNotificationModeKV(rawValue: rawValue)
    }

    public static func == (lhs: CapabilitiesChangedNotificationMode, rhs: CapabilitiesChangedNotificationMode) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    /// Alwayd display notification.
    public static let alwaysDisplay: CapabilitiesChangedNotificationMode = .init(rawValue: "always_display")

    /// Never display notification.
    public static let neverDisplay: CapabilitiesChangedNotificationMode = .init(rawValue: "never_display")
}

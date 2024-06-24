//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

/// Enum defining options for notification about capabilities change.
public struct CapabilitiesChangedNotificationMode: Equatable, RequestStringConvertible {
    internal enum  CapabilitiesChangedNotificationModeKV {
        case always
        case neverDisplay
        case unknown(String)

        var rawValue: String {
            switch self {
            case .always:
                return "always"
            case .neverDisplay:
                return "never"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "always":
                self = .always
            case "never":
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
    public static let alwaysDisplay: CapabilitiesChangedNotificationMode = .init(rawValue: "always")

    /// Never display notification.
    public static let neverDisplay: CapabilitiesChangedNotificationMode = .init(rawValue: "never")
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

/// Enum defining options for captions.
public struct CaptionsVisibilityMode: Equatable, RequestStringConvertible {
    internal enum  CaptionsModeKV {
        case enabled
        case disabled
        case unknown(String)

        var rawValue: String {
            switch self {
            case .enabled:
                return "enabled"
            case .disabled:
                return "disabled"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "enabled":
                self = .enabled
            case "disabled":
                self = .disabled
            default:
                self = .unknown(rawValue.lowercased())
            }
        }
    }

    private let value: CaptionsModeKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = CaptionsModeKV(rawValue: rawValue)
    }

    public static func == (lhs: CaptionsVisibilityMode, rhs: CaptionsVisibilityMode) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    /// Enables the captions.
    public static let enabled: CaptionsVisibilityMode = .init(rawValue: "enabled")

    /// Disables the captions.
    public static let disabled: CaptionsVisibilityMode = .init(rawValue: "disabled")
}

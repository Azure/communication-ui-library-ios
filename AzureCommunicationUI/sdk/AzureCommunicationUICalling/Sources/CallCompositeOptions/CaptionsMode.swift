//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

/// Enum defining options for captions.
public struct CaptionsMode: Equatable, RequestStringConvertible {
    internal enum  CaptionsModeKV {
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

    private let value: CaptionsModeKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = CaptionsModeKV(rawValue: rawValue)
    }

    public static func == (lhs: CaptionsMode, rhs: CaptionsMode) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    /// Enables the captions.
    public static let alwaysEnabled: CaptionsMode = .init(rawValue: "always_enabled")

    /// Disables the captions.
    public static let alwaysDisabled: CaptionsMode = .init(rawValue: "always_disabled")
}

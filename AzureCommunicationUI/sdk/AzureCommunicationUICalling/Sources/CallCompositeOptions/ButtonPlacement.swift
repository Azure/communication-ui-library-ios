//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public struct ButtonPlacement: Equatable, RequestStringConvertible {
    internal enum  ButtonPlacementKV {
        case primaty
        case overflow
        case unknown(String)

        var rawValue: String {
            switch self {
            case .primaty:
                return "primaty"
            case .overflow:
                return "overflow"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "primaty":
                self = .primaty
            case "overflow":
                self = .overflow
            default:
                self = .unknown(rawValue.lowercased())
            }
        }
    }

    private let value: ButtonPlacementKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = ButtonPlacementKV(rawValue: rawValue)
    }

    public static func == (lhs: ButtonPlacement, rhs: ButtonPlacement) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    /// Alwayd display notification.
    public static let primaty: ButtonPlacement = .init(rawValue: "primaty")

    /// Never display notification.
    public static let overflow: ButtonPlacement = .init(rawValue: "never")
}

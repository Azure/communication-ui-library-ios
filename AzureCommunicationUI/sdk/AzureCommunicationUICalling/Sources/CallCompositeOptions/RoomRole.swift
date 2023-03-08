//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import AzureCore

public struct RoomRole: Equatable, RequestStringConvertible {
    internal enum RoomRoleKV {
        case presenter
        case attendee
        case unknown(String)
        var rawValue: String {
            switch self {
            case .presenter:
                return "presenter"
            case .attendee:
                return "attendee"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "presenter":
                self = .presenter
            case "attendee":
                self = .attendee
            default:
                self = .unknown(rawValue.lowercased())
            }
        }
    }

    private let value: RoomRoleKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = RoomRoleKV(rawValue: rawValue)
    }

    public static func == (lhs: RoomRole, rhs: RoomRole) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    public static let presenter: RoomRole = .init(rawValue: "presenter")
    public static let attendee: RoomRole = .init(rawValue: "attendee")
}

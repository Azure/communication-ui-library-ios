//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation

public struct ParticipantRole: Equatable, RequestStringConvertible {
    internal enum ParticipantRoleKV {
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

    private let value: ParticipantRoleKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = ParticipantRoleKV(rawValue: rawValue)
    }

    public static func == (lhs: ParticipantRole, rhs: ParticipantRole) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    public static let presenter: ParticipantRole = .init(rawValue: "presenter")
    public static let attendee: ParticipantRole = .init(rawValue: "attendee")
}

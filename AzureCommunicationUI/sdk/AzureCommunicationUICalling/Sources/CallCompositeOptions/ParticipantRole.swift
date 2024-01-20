//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation
import AzureCommunicationCalling

internal struct ParticipantRole: Equatable, RequestStringConvertible {
    internal enum ParticipantRoleKV {
        case presenter
        case attendee
        case uninitialized
        case consumer
        case organizer
        case coorganizer
        case unknown(String)
        var rawValue: String {
            switch self {
            case .presenter:
                return "presenter"
            case .attendee:
                return "attendee"
            case .uninitialized:
                return "uninitialized"
            case .consumer:
                return "consumer"
            case .organizer:
                return "organizer"
            case .coorganizer:
                return "coorganizer"
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
            case "uninitialized":
                self = .uninitialized
            case "consumer":
                self = .consumer
            case "organizer":
                self = .organizer
            case "coorganizer":
                self = .coorganizer
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

    static let uninitialized: ParticipantRole = .init(rawValue: "uninitialized")
    static let consumer: ParticipantRole = .init(rawValue: "consumer")
    static let organizer: ParticipantRole = .init(rawValue: "organizer")
    static let coorganizer: ParticipantRole = .init(rawValue: "coorganizer")
}

extension AzureCommunicationCalling.CallParticipantRole {
    func toParticipantRole() -> ParticipantRole {
        switch self {
        case .attendee:
            return .attendee
        case .uninitialized:
            return .uninitialized
        case .consumer:
            return .consumer
        case .presenter:
            return .presenter
        case .organizer:
            return .organizer
        case .coOrganizer:
            return .coorganizer
        }
    }
}

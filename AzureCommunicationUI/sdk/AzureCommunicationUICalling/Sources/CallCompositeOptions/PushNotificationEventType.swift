//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation
import AzureCommunicationCalling

/// The type of push notification event.
public struct PushNotificationEventType: Equatable, RequestStringConvertible {
    internal enum PushNotificationEventTypeInternal {
        case incomingCall
        case incomingGroupCall
        case incomingPstnCall
        case stopRinging
        case unknown(String)
        var rawValue: String {
            switch self {
            case .incomingCall:
                return "incomingCall"
            case .incomingGroupCall:
                return "incomingGroupCall"
            case .incomingPstnCall:
                return "incomingPstnCall"
            case .stopRinging:
                return "stopRinging"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "incomingCall":
                self = .incomingCall
            case "incomingGroupCall":
                self = .incomingGroupCall
            case "incomingPstnCall":
                self = .incomingPstnCall
            case "stopRinging":
                self = .stopRinging
            default:
                self = .unknown(rawValue.lowercased())
            }
        }
    }

    private let value: PushNotificationEventTypeInternal

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = PushNotificationEventTypeInternal(rawValue: rawValue)
    }

    public static func == (lhs: PushNotificationEventType,
                           rhs: PushNotificationEventType) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    public static let incomingCall: PushNotificationEventType = .init(rawValue: "incomingCall")
    public static let incomingGroupCall: PushNotificationEventType = .init(rawValue: "incomingGroupCall")
    public static let incomingPstnCall: PushNotificationEventType = .init(rawValue: "incomingPstnCall")
    public static let stopRinging: PushNotificationEventType = .init(rawValue: "stopRinging")
}

extension AzureCommunicationCalling.PushNotificationEventType {
    func toPushNotificationEventType() -> PushNotificationEventType {
        switch self {
        case .incomingCall:
            return .incomingCall
        case .incomingGroupCall:
            return .incomingGroupCall
        case .incomingPstnCall:
            return .incomingPstnCall
        case .stopRinging:
            return .stopRinging
        }
    }
}

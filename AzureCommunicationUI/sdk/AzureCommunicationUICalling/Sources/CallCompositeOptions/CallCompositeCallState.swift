//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureCore

/// Defines values for call state.
public struct CallState: Equatable, RequestStringConvertible {

    internal enum CallStateKV {
        case none
        case earlyMedia
        case connecting
        case ringing
        case connected
        case localHold
        case disconnecting
        case disconnected
        case inLobby
        case remoteHold
        case unknown(String)

        var rawValue: String {
            switch self {
            case .none:
                return "none"
            case .earlyMedia:
                return "earlyMedia"
            case .connecting:
                return "connecting"
            case .ringing:
                return "ringing"
            case .connected:
                return "connected"
            case .localHold:
                return "localHold"
            case .disconnecting:
                return "disconnecting"
            case .disconnected:
                return "disconnected"
            case .inLobby:
                return "inLobby"
            case .remoteHold:
                return "remoteHold"
            case .unknown(let value):
                return value
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "none":
                self = .none
            case "earlyMedia":
                self = .earlyMedia
            case "connecting":
                self = .connecting
            case "ringing":
                self = .ringing
            case "connected":
                self = .connected
            case "localHold":
                self = .localHold
            case "disconnecting":
                self = .disconnecting
            case "disconnected":
                self = .disconnected
            case "inLobby":
                self = .inLobby
            case "remoteHold":
                self = .remoteHold
            default:
                self = .unknown(rawValue.lowercased())
            }
        }
    }

    private let value: CallStateKV
    private let callEndReasonCode: Int?
    private let callEndReasonSubCode: Int?

    public var requestString: String {
        return value.rawValue
    }

    public var callEndReasonCodeInt: Int? {
        return callEndReasonCode
    }

    public var callEndReasonSubCodeInt: Int? {
        return callEndReasonSubCode
    }

    private init(rawValue: String) {
        self.value = CallStateKV(rawValue: rawValue)
        self.callEndReasonCode = 0
        self.callEndReasonSubCode = 0
    }

    public init(rawValue: String,
                callEndReasonCode: Int?,
                callEndReasonSubCode: Int?) {
        self.value = CallStateKV(rawValue: rawValue)
        self.callEndReasonCode = callEndReasonCode
        self.callEndReasonSubCode = callEndReasonSubCode
    }

    public static func == (lhs: CallState, rhs: CallState) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    /// None - disposed or applicable very early in lifetime of a call.
    public static let none: CallState = .init(rawValue: "none")
    /// Early Media.
    public static let earlyMedia: CallState = .init(rawValue: "earlyMedia")
    /// Call is being connected.
    public static let connecting: CallState = .init(rawValue: "connecting")
    /// Call is ringing.
    public static let ringing: CallState = .init(rawValue: "ringing")
    /// Call is connected.
    public static let connected: CallState = .init(rawValue: "connected")
    /// Call held by local participant.
    public static let localHold: CallState = .init(rawValue: "localHold")
    /// None - disposed or applicable very early in lifetime of a call.
    public static let disconnecting: CallState = .init(rawValue: "disconnecting")
    /// Call is being disconnected.
    public static let disconnected: CallState = .init(rawValue: "disconnected")
    /// In Lobby.
    public static let inLobby: CallState = .init(rawValue: "inLobby")
    /// Call held by a remote participant.
    public static let remoteHold: CallState = .init(rawValue: "remoteHold")
}

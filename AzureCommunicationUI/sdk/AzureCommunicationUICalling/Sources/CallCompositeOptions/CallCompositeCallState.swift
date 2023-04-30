//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Defines values for CallCompositeCallState.
public struct CallCompositeCallStateCode {
    /// None - disposed or applicable very early in lifetime of a call.
    public static let none: String = "none"

    /// Early Media.
    public static let earlyMedia: String = "earlyMedia"

    /// Call is being connected.
    public static let connecting: String = "connecting"

    /// Call is ringing.
    public static let ringing: String = "ringing"

    /// Call is connected.
    public static let connected: String = "connected"

    /// Call held by local participant.
    public static let localHold: String = "localHold"

    /// None - disposed or applicable very early in lifetime of a call.
    public static let disconnecting: String = "disconnecting"

    /// Call is being disconnected.
    public static let disconnected: String = "disconnected"

    /// In Lobby.
    public static let inLobby: String = "inLobby"

    /// Call held by a remote participant.
    public static let remoteHold: String = "remoteHold"
}

/// The call state after Call Composite launching.
public struct CallCompositeCallState {
    /// The string representing the CallCompositeCallState.
    public let code: String
}

extension CallCompositeCallState: Equatable {
    public static func == (lhs: CallCompositeCallState, rhs: CallCompositeCallState) -> Bool {
            return lhs.code == rhs.code
    }
}

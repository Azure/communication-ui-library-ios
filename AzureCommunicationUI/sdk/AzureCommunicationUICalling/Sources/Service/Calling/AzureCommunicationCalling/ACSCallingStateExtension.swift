//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

extension AzureCommunicationCalling.CallState {
    func toCallingStatus() -> CallingStatus {
        switch self {
        case .none:
            return .none
        case .earlyMedia:
            return .earlyMedia
        case .connecting:
            return .connecting
        case .ringing:
            return .ringing
        case .connected:
            return .connected
        case .localHold:
            return .localHold
        case .disconnecting:
            return .disconnecting
        case .disconnected:
            return .disconnected
        case .inLobby:
            return .inLobby
        case .remoteHold:
            return .remoteHold
        default:
            return .none
        }
    }
}

extension CallingStatus {
    func toCallCompositeCallState() -> CallState {
        switch self {
        case .none:
            return CallState.none
        case .earlyMedia:
            return CallState.earlyMedia
        case .connecting:
            return CallState.connecting
        case .ringing:
            return CallState.ringing
        case .connected:
            return CallState.connected
        case .localHold:
            return CallState.localHold
        case .disconnecting:
            return CallState.disconnecting
        case .disconnected:
            return CallState.disconnected
        case .inLobby:
            return CallState.inLobby
        case .remoteHold:
            return CallState.remoteHold
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

extension CallState {
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
    func toCallCompositeCallState() -> String {
        switch self {
        case .none:
            return CallCompositeCallState.none
        case .earlyMedia:
            return CallCompositeCallState.earlyMedia
        case .connecting:
            return CallCompositeCallState.connecting
        case .ringing:
            return CallCompositeCallState.ringing
        case .connected:
            return CallCompositeCallState.connected
        case .localHold:
            return CallCompositeCallState.localHold
        case .disconnecting:
            return CallCompositeCallState.disconnecting
        case .disconnected:
            return CallCompositeCallState.disconnected
        case .inLobby:
            return CallCompositeCallState.inLobby
        case .remoteHold:
            return CallCompositeCallState.remoteHold
        }
    }
}

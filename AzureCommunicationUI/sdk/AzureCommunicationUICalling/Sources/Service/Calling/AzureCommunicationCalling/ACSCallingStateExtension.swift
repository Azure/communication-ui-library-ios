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
            return CallCompositeCallStateCode.none
        case .earlyMedia:
            return CallCompositeCallStateCode.earlyMedia
        case .connecting:
            return CallCompositeCallStateCode.connecting
        case .ringing:
            return CallCompositeCallStateCode.ringing
        case .connected:
            return CallCompositeCallStateCode.connected
        case .localHold:
            return CallCompositeCallStateCode.localHold
        case .disconnecting:
            return CallCompositeCallStateCode.disconnecting
        case .disconnected:
            return CallCompositeCallStateCode.disconnected
        case .inLobby:
            return CallCompositeCallStateCode.inLobby
        case .remoteHold:
            return CallCompositeCallStateCode.remoteHold
        }
    }
}

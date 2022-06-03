//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

extension ParticipantState {
    func toCompositeParticipantStatus() -> ParticipantStatus {
        switch self {
        case .idle:
            return .idle
        case .earlyMedia:
            return .earlyMedia
        case .connecting:
            return .connecting
        case .connected:
            return .connected
        case .hold:
            return .hold
        case .inLobby:
            return .inLobby
        case .disconnected:
            return .disconnected
        case .ringing:
            return .ringing
        default:
            return .idle
        }
    }
}

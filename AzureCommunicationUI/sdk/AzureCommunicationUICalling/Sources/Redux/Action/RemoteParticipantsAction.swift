//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum RemoteParticipantsAction: Equatable {
    case dominantSpeakersUpdated(speakers: [String])
    case participantListUpdated(participants: [ParticipantInfoModel])
    case admitAll
    case declineAll
    case admit(participantId: String)
    case decline(participantId: String)
    case lobbyError(errorCode: LobbyErrorCode)
}

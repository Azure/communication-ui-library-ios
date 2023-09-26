//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum RemoteParticipantsAction: Equatable {
    case dominantSpeakersUpdated(speakers: [String])
    case participantListUpdated(participants: [ParticipantInfoModel])
    case admitAllLobbyParticipants
    case admitLobbyParticipant(participantId: String)
}

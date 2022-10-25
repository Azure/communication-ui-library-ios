//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation

extension Reducer where State == ParticipantsState,
                        Actions == Action {
    static var liveParticipantsReducer: Self = Reducer { participantsState, action in

        switch action {
        case .participantsAction(.participantsAdded(let participants)):
            let count = participantsState.numberOfParticipants + participants.count
            var currentParticipants = participantsState.participants
            for participant in participants {
                currentParticipants[participant.id] = participant
            }
            let state = ParticipantsState(numberOfParticipants: count,
                                          participants: currentParticipants)
            return state
        case .participantsAction(.participantsRemoved(let participants)):
            let count = participantsState.numberOfParticipants - participants.count
            var currentParticipants = participantsState.participants
            for participant in participants {
                guard currentParticipants[participant.id] != nil else {
                    continue
                }

                currentParticipants.removeValue(forKey: participant.id)
            }
            let state = ParticipantsState(numberOfParticipants: count,
                                          participants: currentParticipants)
        default:
            return participantsState
        }

        return participantsState
    }
}

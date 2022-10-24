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
            var threadParticipants = participantsState.threadParticipants
            threadParticipants.append(contentsOf: participants)
            let state = ParticipantsState(numberOfParticipants: count,
                                          threadParticipants: threadParticipants)
            return state
        case .participantsAction(.participantsRemoved(let participants)):
            print("ParticipantsReducer `participantsRemoved` not implemented")
        default:
            return participantsState
        }

        return participantsState
    }
}

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
            print("ParticipantsReducer `participantsAdded` not implemented")
        case .participantsAction(.participantsRemoved(let participants)):
            print("ParticipantsReducer `participantsRemoved` not implemented")
        default:
            return participantsState
        }

        return ParticipantsState()
    }
}

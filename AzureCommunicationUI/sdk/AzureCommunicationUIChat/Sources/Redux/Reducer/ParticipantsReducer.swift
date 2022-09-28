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
        case .participantsAction(.leaveChatSuccess):
            print("ParticipantsReducer `leaveChatSuccess` not implemented")
        default:
            return participantsState
        }

        return ParticipantsState()
    }
}

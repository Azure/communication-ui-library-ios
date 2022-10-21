//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation

extension Reducer where State == ParticipantsState,
                        Actions == Action {
    static var liveParticipantsReducer: Self = Reducer { participantsState, action in
        // MARK: Chat Participant
        var participantsInfoMap = participantsState.participantsInfoMap
        var participantsUpdatedTimestamp = participantsState.participantsUpdatedTimestamp

        // MARK: Typing Indicator
        let currentTimestamp = Date()
        let speakingDurationSeconds: TimeInterval = 8
        var typingIndicatorMap = participantsState.typingIndicatorMap

        switch action {
        case .participantsAction(.participantsAdded(let participants)):
            print("ParticipantsReducer `participantsAdded` not implemented")
        case .participantsAction(.participantsRemoved(let participants)):
            print("ParticipantsReducer `participantsRemoved` not implemented")
            // missing participantsInfoMap, readReceiptMap
            for p in participants {
                participantsInfoMap.removeValue(forKey: p.id)
                typingIndicatorMap[p.id]?.fire()
            }
        case .participantsAction(.typingIndicatorReceived(let id, let timer)):
            typingIndicatorMap[id]?.invalidate()
            typingIndicatorMap[id] = timer
        case .participantsAction(.clearTypingIndicator(let id)):
            typingIndicatorMap[id] = nil
        case .repositoryAction(.chatMessageReceived(let message)):
            guard let participantId = message.senderId else {
                return participantsState
            }
            switch message.type {
            case .custom(_), .html, .text:
                typingIndicatorMap[participantId]?.fire()
            default:
                return participantsState
            }
        default:
            return participantsState
        }

        return ParticipantsState(participantsInfoMap: participantsInfoMap,
                                 participantsUpdatedTimestamp: participantsUpdatedTimestamp,
                                 typingIndicatorMap: typingIndicatorMap)
    }
}

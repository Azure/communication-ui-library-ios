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
        var currentParticipants = participantsState.participants
        var participantsUpdatedTimestamp = participantsState.participantsUpdatedTimestamp

        // MARK: Typing Indicator
        let currentTimestamp = Date()
        let speakingDurationSeconds: TimeInterval = 8
        var typingIndicatorMap = participantsState.typingIndicatorMap

        switch action {
        case .participantsAction(.participantsAdded(let participants)):
            var currentParticipants = participantsState.participants
            for participant in participants {
                currentParticipants[participant.id] = participant
            }
            let state = ParticipantsState(participants: currentParticipants)
            return state
        case .participantsAction(.participantsRemoved(let participants)):
            for participant in participants {
                guard currentParticipants[participant.id] != nil else {
                    continue
                }
                currentParticipants.removeValue(forKey: participant.id)
                typingIndicatorMap[participant.id]?.fire()
            }
            participantsUpdatedTimestamp = currentTimestamp

            let state = ParticipantsState(participants: currentParticipants,
                                          participantsUpdatedTimestamp: participantsUpdatedTimestamp)

            return state
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

        return ParticipantsState(participants: currentParticipants,
                                 participantsUpdatedTimestamp: participantsUpdatedTimestamp,
                                 typingIndicatorMap: typingIndicatorMap)
    }
}

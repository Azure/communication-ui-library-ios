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
        let currentTimestamp = Date()
        
        // MARK: Typing Indicator
        var typingParticipants = participantsState.typingParticipants

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
                typingParticipants = typingParticipants.filter { $0.id != participant.id }
                currentParticipants.removeValue(forKey: participant.id)
            }
            participantsUpdatedTimestamp = currentTimestamp
            let state = ParticipantsState(participants: currentParticipants,
                                          participantsUpdatedTimestamp: participantsUpdatedTimestamp)
            return state
        case .participantsAction(.typingIndicatorReceived(let participant)):
            typingParticipants = typingParticipants.filter { $0.id != participant.id }
            typingParticipants.append(participant)
        case .participantsAction(.setTypingIndicator(let newParticipants)):
            typingParticipants = newParticipants
        case .repositoryAction(.chatMessageReceived(let message)):
            guard let participantId = message.senderId else {
                break
            }
            switch message.type {
            case .custom(_), .html, .text:
                typingParticipants = typingParticipants.filter { $0.id != participantId }
            default:
                break
            }
        default:
            return participantsState
        }

        return ParticipantsState(participants: currentParticipants,
                                 participantsUpdatedTimestamp: participantsUpdatedTimestamp,
                                 typingParticipants: typingParticipants)
    }
}

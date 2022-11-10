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
        var typingIndicatorTimestamp = participantsState.typingIndicatorUpdatedTimestamp

        // MARK: Read Receipt
        var readReceiptMap = participantsState.readReceiptMap
        var readReceiptUpdatedTimestamp = participantsState.readReceiptUpdatedTimestamp

        switch action {
        case .participantsAction(.participantsAdded(let participants)):
            var currentParticipants = participantsState.participants
            for participant in participants {
                currentParticipants[participant.id] = participant
                readReceiptMap[participant.id] = .distantPast
            }
            let state = ParticipantsState(participants: currentParticipants)
            return state
        case .participantsAction(.participantsRemoved(let participants)):
            for participant in participants {
                guard currentParticipants[participant.id] != nil else {
                    continue
                }

                currentParticipants.removeValue(forKey: participant.id)
                typingIndicatorMap.removeValue(forKey: participant.id)
                readReceiptMap.removeValue(forKey: participant.id)
            }
            participantsUpdatedTimestamp = currentTimestamp
            typingIndicatorTimestamp = currentTimestamp

            let state = ParticipantsState(participants: currentParticipants,
                                          participantsUpdatedTimestamp: participantsUpdatedTimestamp)

            return state
        case .participantsAction(.typingIndicatorReceived(userEventTimestamp: let userEventTimestamp)):
            let typingExpiringTimestamp = userEventTimestamp.timestamp.value + speakingDurationSeconds
            typingIndicatorMap[userEventTimestamp.id] = typingExpiringTimestamp
            if typingIndicatorTimestamp < typingExpiringTimestamp {
                typingIndicatorTimestamp = typingExpiringTimestamp
            }
        case .participantsAction(.readReceiptReceived(readReceiptInfo: let readReceiptInfo)):
            let senderIdentifier = readReceiptInfo.senderIdentifier
            let readOn = readReceiptInfo.readOn
            let messageId = readReceiptInfo.chatMessageId
            readReceiptMap[senderIdentifier.stringValue] = messageId.convertEpochStringToTimestamp()
            let minimumReadReceiptTimestamp = readReceiptMap.min { $0.value < $1.value }?.value
            guard let minimumReadReceiptTimestamp = minimumReadReceiptTimestamp else {
                return participantsState
            }
            readReceiptUpdatedTimestamp = minimumReadReceiptTimestamp

        case .repositoryAction(.chatMessageReceived(let message)):
            guard let participantId = message.senderId else {
                return participantsState
            }
            switch message.type {
            case .custom(_), .html, .text:
                typingIndicatorMap.removeValue(forKey: participantId)
                typingIndicatorTimestamp = currentTimestamp
            default:
                return participantsState
            }
        default:
            return participantsState
        }

        return ParticipantsState(participants: currentParticipants,
                                 participantsUpdatedTimestamp: participantsUpdatedTimestamp,
                                 typingIndicatorMap: typingIndicatorMap,
                                 typingIndicatorUpdatedTimestamp: typingIndicatorTimestamp,
                                 readReceiptMap: readReceiptMap,
                                 readReceiptUpdatedTimestamp: readReceiptUpdatedTimestamp)
    }
}

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
        var typingParticipants = participantsState.typingParticipants

        // MARK: Read Receipt
        var readReceiptMap = participantsState.readReceiptMap
        var readReceiptUpdatedTimestamp = participantsState.readReceiptUpdatedTimestamp

        switch action {
        case .participantsAction(.fetchListOfParticipantsSuccess(let participants, let localParticipantId)):
            var newParticipants: [String: ParticipantInfoModel] = [:]
            for participant in participants {
                newParticipants[participant.id] = participant
                if readReceiptMap[participant.id] == nil && participant.id != localParticipantId {
                    readReceiptMap[participant.id] = .distantPast
                }
            }
            currentParticipants = newParticipants
            typingParticipants = []
            participantsUpdatedTimestamp = Date()
        case .participantsAction(.participantsAdded(let participants)):
            for participant in participants {
                currentParticipants[participant.id] = participant
                if readReceiptMap[participant.id] == nil {
                    readReceiptMap[participant.id] = .distantPast
                }
            }
            participantsUpdatedTimestamp = Date()

        case .participantsAction(.participantsRemoved(let participants)):
            for participant in participants {
                guard currentParticipants[participant.id] != nil else {
                    continue
                }
                typingParticipants = typingParticipants.filter { $0.id != participant.id }
                currentParticipants.removeValue(forKey: participant.id)
                readReceiptMap.removeValue(forKey: participant.id)
            }
            participantsUpdatedTimestamp = Date()
        case .participantsAction(.typingIndicatorReceived(let participant)):
            typingParticipants = typingParticipants.filter { $0.id != participant.id }
            typingParticipants.append(participant)
        case .participantsAction(.clearIdleTypingParticipants):
            typingParticipants = typingParticipants.filter(\.isTyping)
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
                                 typingParticipants: typingParticipants,
                                 readReceiptMap: readReceiptMap,
                                 readReceiptUpdatedTimestamp: readReceiptUpdatedTimestamp)
    }
}

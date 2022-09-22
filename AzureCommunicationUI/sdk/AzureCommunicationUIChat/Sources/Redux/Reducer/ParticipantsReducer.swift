//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import AzureCore

extension Reducer where State == ParticipantsState,
                        Actions == Action {
    static var liveParticipantsReducer: Self = Reducer { participantsState, action in

        let speakingDurationSeconds: TimeInterval = 8
        let currentTimestamp = Date()

        var participantsInfoMap = participantsState.participantsInfoMap
        var readReceiptMap = participantsState.readReceiptMap
        var typingIndicatorMap = participantsState.typingIndicatorMap

        var participantsUpdatedTimestamp = participantsState.participantsUpdatedTimestamp
        var readReceiptTimestamp = participantsState.readReceiptUpdatedTimestamp
        var typingIndicatorTimestamp = participantsState.typingIndicatorUpdatedTimestamp

        switch action {
        case .participantsAction(.retrieveParticipantsListTriggered):
            print("ParticipantsReducer `retrieveParticipantsListTriggered` not implemented")
        case .participantsAction(.retrieveParticipantsListSuccess(let participants)):
            for p in participants {
                participantsInfoMap[p.id] = p
                readReceiptMap[p.id] = currentTimestamp
            }
            participantsUpdatedTimestamp = currentTimestamp
            print(".retrieveParticipantsListSuccess adding \(participants.count) participants")
        case .participantsAction(.retrieveParticipantsListFailed(let error)):
            print("ParticipantsReducer `retrieveParticipantsListFailed` not implemented")
        case .participantsAction(.removeParticipantTriggered(let participant)):
            print("ParticipantsReducer `removeParticipantTriggered` not implemented")
        case .participantsAction(.removeParticipantSuccess):
            print("ParticipantsReducer `removeParticipantSuccess` not implemented")
        case .participantsAction(.removeParticipantFailed):
            print("ParticipantsReducer `removeParticipantFailed` not implemented")
        case .participantsAction(.leaveChatTriggered):
            print("ParticipantsReducer `leaveChatTriggered` not implemented")
        case .participantsAction(.leaveChatSuccess):
            print("ParticipantsReducer `leaveChatSuccess` not implemented")
        case .participantsAction(.leaveChatFailed(let error)):
            print("ParticipantsReducer `leaveChatFailed` not implemented")

        // Remote user event received
        case .participantsAction(.participantsAddedReceived(let participants)):
            for p in participants {
                participantsInfoMap[p.id] = p
                readReceiptMap[p.id] = currentTimestamp
            }
            participantsUpdatedTimestamp = currentTimestamp
            print("ParticipantsReducer `participantAddedReceived` participant count: \(participants.count)")
        case .participantsAction(.participantsRemovedReceived(let participants)):
            for p in participants {
                participantsInfoMap.removeValue(forKey: p.id)
                readReceiptMap.removeValue(forKey: p.id)
                typingIndicatorMap.removeValue(forKey: p.id)
            }
            participantsUpdatedTimestamp = currentTimestamp
            if let minReadTimestamp = readReceiptMap.values.min() {
                readReceiptTimestamp = minReadTimestamp
            }
            typingIndicatorTimestamp = currentTimestamp
        case .participantsAction(.typingIndicatorReceived(let userEventTimestamp)):
            let typingExpiringTimestamp = userEventTimestamp.timestamp.value + speakingDurationSeconds
            typingIndicatorMap[userEventTimestamp.id] = typingExpiringTimestamp
            if typingIndicatorTimestamp < typingExpiringTimestamp {
                typingIndicatorTimestamp = typingExpiringTimestamp
            }
        case .participantsAction(.messageReadReceived(let userEventTimestamp)):
            // may want to do some throttling and accumulate these
            // because everyone might read it the same time, to only do reduce state
            readReceiptMap[userEventTimestamp.id] = userEventTimestamp.timestamp.value
//            if let minTimestamp = readReceiptMap.values.min() {
//                readReceiptTimestamp = minTimestamp
//            }
            readReceiptTimestamp = Date()
        // ChatAction
        case .chatAction(.messageReceived(let message)):
            if let participantId = message.senderId, message.type == .text {
                typingIndicatorMap.removeValue(forKey: participantId)
                typingIndicatorTimestamp = currentTimestamp
            }

        default:
            return participantsState
        }

        return ParticipantsState(
            participantsInfoMap: participantsInfoMap,
            readReceiptMap: readReceiptMap,
            typingIndicatorMap: typingIndicatorMap,
            participantsUpdatedTimestamp: participantsUpdatedTimestamp,
            readReceiptUpdatedTimestamp: readReceiptTimestamp,
            typingIndicatorUpdatedTimestamp: typingIndicatorTimestamp)
    }
}

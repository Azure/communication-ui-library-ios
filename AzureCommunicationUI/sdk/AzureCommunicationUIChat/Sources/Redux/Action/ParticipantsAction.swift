//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

enum ParticipantsAction: Equatable {

    // User action
    case retrieveParticipantsListTriggered
    case retrieveParticipantsListSuccess(participants: [ParticipantInfoModel])
    case retrieveParticipantsListFailed(error: Error)

    // removing other parcipants
    case removeParticipantTriggered(participant: ParticipantInfoModel)
    case removeParticipantSuccess
    case removeParticipantFailed(error: Error)

    // same chatSDK removeParticipant but removing local user id
    case leaveChatTriggered
    case leaveChatSuccess
    case leaveChatFailed(error: Error)

    // Remote user event received from ChatSDKEventsHandler
    case participantsAddedReceived(participants: [ParticipantInfoModel])
    case participantsRemovedReceived(participants: [ParticipantInfoModel])
    case typingIndicatorReceived(userEventTimestamp: UserEventTimestampModel)
    case messageReadReceived(userEventTimestamp: UserEventTimestampModel)

    static func == (lhs: ParticipantsAction, rhs: ParticipantsAction) -> Bool {

        switch (lhs, rhs) {
        case let (.retrieveParticipantsListFailed(lErr), .retrieveParticipantsListFailed(rErr)),
            let (.removeParticipantFailed(lErr), .removeParticipantFailed(rErr)),
            let (.leaveChatFailed(lErr), .leaveChatFailed(rErr)):
            return (lErr as NSError).code == (rErr as NSError).code

        case (.retrieveParticipantsListTriggered, .retrieveParticipantsListTriggered),
            (.removeParticipantSuccess, .removeParticipantSuccess),
            (.leaveChatSuccess, .leaveChatSuccess),
            (.leaveChatTriggered, .leaveChatTriggered):
            return true

        case let (.retrieveParticipantsListSuccess(lParticipantList),
                  .retrieveParticipantsListSuccess(rParticipantList)),
            let (.participantsAddedReceived(lParticipantList),
                 .participantsAddedReceived(rParticipantList)),
            let (.participantsRemovedReceived(lParticipantList),
                 .participantsRemovedReceived(rParticipantList)):
            return lParticipantList == rParticipantList

        case let (.typingIndicatorReceived(lUserTimestamp), .typingIndicatorReceived(rUserTimestamp)),
            let (.messageReadReceived(lUserTimestamp), .messageReadReceived(rUserTimestamp)):
            return lUserTimestamp == rUserTimestamp

        case let (.removeParticipantTriggered(lParticipant), .removeParticipantTriggered(rParticipant)):
            return lParticipant == rParticipant

        default:
            return false
        }
    }
}

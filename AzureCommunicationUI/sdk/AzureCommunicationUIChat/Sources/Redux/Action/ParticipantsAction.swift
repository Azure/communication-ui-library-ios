//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ParticipantsAction: Equatable {
    // MARK: - Chat SDK Local Event Actions
    case fetchListOfParticipantsFailed(error: Error)

    case leaveChatSuccess

    // MARK: - Chat SDK Remote Event Actions
    case typingIndicatorReceived(userEventTimestamp: UserEventTimestampModel)
    case participantsAdded(participants: [ParticipantInfoModel])
    case participantsRemoved(participants: [ParticipantInfoModel])
    case localParticipantRemoved

    case sendReadReceiptTriggered(messageId: String)
    case sendReadReceiptSuccess(messageId: String)
    case sendReadReceiptFailed(error: Error)

    static func == (lhs: ParticipantsAction, rhs: ParticipantsAction) -> Bool {
        switch (lhs, rhs) {
        case let (.sendReadReceiptFailed(lErr), .sendReadReceiptFailed(rErr)):
            return (lErr as NSError).code == (rErr as NSError).code

        case let (.sendReadReceiptTriggered(lMsgId), .sendReadReceiptTriggered(rMsgId)),
              let (.sendReadReceiptSuccess(lMsgId), .sendReadReceiptSuccess(rMsgId)):
            return lMsgId == rMsgId

        default:
            return false
        }
    }
}

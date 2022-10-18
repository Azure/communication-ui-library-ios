//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatAction: Equatable {
    case initializeChatTriggered
    case initializeChatFailed(error: Error)
    case topicRetrieved(topic: String)

    // MARK: Events from SDK
    case realTimeNotificationConnected
    case realTimeNotificationDisconnected
    case chatThreadDeleted
    case chatTopicUpdated(topic: String)

    case sendReadReceiptTriggered(messageId: String)
    case sendReadReceiptSuccess
    case sendReadReceiptFailed(error: Error)

    static func == (lhs: ChatAction, rhs: ChatAction) -> Bool {
        switch (lhs, rhs) {
        case let (.initializeChatFailed(lErr), .initializeChatFailed(rErr)),
            let (.sendReadReceiptFailed(lErr), .sendReadReceiptFailed(rErr)):
            return (lErr as NSError).code == (rErr as NSError).code

        case (.initializeChatTriggered, .initializeChatTriggered),
            (.sendReadReceiptTriggered, .sendReadReceiptTriggered),
            (.sendReadReceiptSuccess, .sendReadReceiptSuccess):
            return true

        case let (.topicRetrieved(lStr), .topicRetrieved(rStr)):
            return lStr == rStr

        default:
            return false
        }
    }
}

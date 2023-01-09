//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatAction: Equatable {
    case initializeChatTriggered
    case initializeChatSuccess
    case initializeChatFailed(error: Error)
    case topicRetrieved(topic: String)
    case disconnectChatTriggered
    case disconnectChatSuccess
    case disconnectChatFailed(error: Error)

    // MARK: Events from SDK
    case realTimeNotificationConnected
    case realTimeNotificationDisconnected
    case chatThreadDeleted
    case chatTopicUpdated(threadInfo: ChatThreadInfoModel)
    case chatMessageLocalUserRemoved

    case sendTypingIndicatorTriggered
    case sendTypingIndicatorSuccess
    case sendTypingIndicatorFailed(error: Error)

    static func == (lhs: ChatAction, rhs: ChatAction) -> Bool {
        switch (lhs, rhs) {
        case let (.initializeChatFailed(lErr), .initializeChatFailed(rErr)),
            let (.sendTypingIndicatorFailed(lErr), .sendTypingIndicatorFailed(rErr)):
            return (lErr as NSError).code == (rErr as NSError).code

        case (.initializeChatTriggered, .initializeChatTriggered),
            (.sendTypingIndicatorTriggered, .sendTypingIndicatorTriggered),
            (.sendTypingIndicatorSuccess, .sendTypingIndicatorSuccess):
            return true

        case let (.topicRetrieved(lStr), .topicRetrieved(rStr)):
            return lStr == rStr

        case let (.chatTopicUpdated(lInfo), .chatTopicUpdated(rInfo)):
            return lInfo == rInfo

        default:
            return false
        }
    }
}

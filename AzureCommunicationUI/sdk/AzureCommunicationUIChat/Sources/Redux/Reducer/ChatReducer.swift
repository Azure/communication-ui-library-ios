//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation

extension Reducer where State == ChatState,
                        Actions == Action {
    static var liveChatReducer: Self = Reducer { chatState, action in
        var localUser = chatState.localUser
        var threadId = chatState.threadId
        var topic = chatState.topic
        var lastReadReceiptSentTimestamp = chatState.lastReadReceiptSentTimestamp

        switch action {
        case .chatAction(.topicRetrieved(let newTopic)):
            topic = newTopic
        case .chatAction(.chatTopicUpdated(let threadInfo)):
            guard let newTopic = threadInfo.topic else {
                break
            }
            topic = newTopic
        case .participantsAction(.sendReadReceiptSuccess(messageId: let messageId)):
            lastReadReceiptSentTimestamp = messageId.convertEpochStringToTimestamp()
        default:
            return chatState
        }
        return ChatState(localUser: localUser,
                         threadId: threadId,
                         topic: topic)
    }
}

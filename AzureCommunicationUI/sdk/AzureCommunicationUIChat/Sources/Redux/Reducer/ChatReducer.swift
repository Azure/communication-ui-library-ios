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
        var lastReadReceiptReceivedTimestamp = chatState.lastReadReceiptReceivedTimestamp
        var lastReadReceiptSentTimestamp = chatState.lastReadReceiptSentTimestamp
        var lastReceivedMessageTimestamp = chatState.lastReceivedMessageTimestamp
        var lastSendingMessageTimestamp = chatState.lastSendingMessageTimestamp
        var lastSentOrFailedMessageTimestamp = chatState.lastSentOrFailedMessageTimestamp
        var isLocalUserRemovedFromChat = chatState.isLocalUserRemovedFromChat

        switch action {
        case .chatAction(.topicRetrieved(let newTopic)):
            topic = newTopic
        case .chatAction(.chatTopicUpdated(let threadInfo)):
            guard let newTopic = threadInfo.topic else {
                break
            }
            topic = newTopic
        case .chatAction(.chatMessageLocalUserRemoved):
            isLocalUserRemovedFromChat = true
        case .participantsAction(.readReceiptReceived(_)):
            lastReadReceiptReceivedTimestamp = Date()
        case .participantsAction(.sendReadReceiptSuccess(messageId: let messageId)):
            lastReadReceiptSentTimestamp = messageId.convertEpochStringToTimestamp()
        case .repositoryAction(.sendMessageTriggered(_, _)):
            lastSendingMessageTimestamp = Date()
        case .repositoryAction(.sendMessageSuccess(_, _)),
             .repositoryAction(.sendMessageFailed(_, _)):
            lastSentOrFailedMessageTimestamp = Date()
        case .repositoryAction(.chatMessageReceived(let message)):
            if !message.isLocalUser {
                lastReceivedMessageTimestamp = Date()
            }
        default:
            return chatState
        }
        return ChatState(localUser: localUser,
                         threadId: threadId,
                         topic: topic,
                         lastReadReceiptReceivedTimestamp: lastReadReceiptReceivedTimestamp,
                         lastReadReceiptSentTimestamp: lastReadReceiptSentTimestamp,
                         lastReceivedMessageTimestamp: lastReceivedMessageTimestamp,
                         lastSendingMessageTimestamp: lastSendingMessageTimestamp,
                         lastSentOrFailedMessageTimestamp: lastSentOrFailedMessageTimestamp,
                         isLocalUserRemovedFromChat: isLocalUserRemovedFromChat)
    }
}

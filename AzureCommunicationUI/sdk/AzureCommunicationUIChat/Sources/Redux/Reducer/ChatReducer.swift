//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCore

extension Reducer where State == ChatState,
                        Actions == Action {
    static var liveChatReducer: Self = Reducer { chatState, action in

        var localUser = chatState.localUser
        var topic = chatState.topic
        var messages = chatState.messages
        var messagesLastUpdatedTimestamp = chatState.messagesLastUpdatedTimestamp

        switch action {
        case .chatAction(.loadInitialMessagesSuccess(let initialMessages)):
            messagesLastUpdatedTimestamp = Date()
        case .chatAction(.loadInitialMessagesFailed(let error)):
            print("ChatReducer `loadInitialMessagesFailed` not handled")
        case .chatAction(.fetchPreviousMessagesTriggered):
            print("ChatReducer `fetchPreviousMessagesTriggered` not handled")
        case .chatAction(.fetchPreviousMessagesSuccess(let messages)):
            print("ChatReducer `fetchPreviousMessagesSuccess` not handled")
            messagesLastUpdatedTimestamp = Date()
        case .chatAction(.fetchPreviousMessagessFailed(let error)):
            print("ChatReducer `fetchPreviousMessagessFailed` not handled")
        case .chatAction(.sendTypingIndicatorTriggered):
            print("ChatReducer `sendTypingIndicatorTriggered` not handled")
        case .chatAction(.sendTypingIndicatorSuccess):
            print("ChatReducer `sendTypingIndicatorSuccess` not handled")
        case .chatAction(.sendTypingIndicatorFailed(let error)):
            print("ChatReducer `sendTypingIndicatorFailed` not handled")
        case .chatAction(.sendReadReceiptTriggered(let messageId)):
            print("ChatReducer `sendReadReceiptTriggered` not handled")
        case .chatAction(.sendReadReceiptSuccess):
            print("ChatReducer `sendReadReceiptSuccess` not handled")
        case .chatAction(.sendReadReceiptFailed(let error)):
            print("ChatReducer `sendReadReceiptFailed` not handled")
        case .chatAction(.sendMessageTriggered(let newMessage)):
            messagesLastUpdatedTimestamp = Date()
        case .chatAction(.sendMessageSuccess(let newMessage)):
            print("Reducer sendMessageSuccess: \(newMessage.id) \(newMessage.internalId)")
            messagesLastUpdatedTimestamp = Date()
        case .chatAction(.sendMessageFailed(let error)):
            print("ChatReducer: failed to send message \(error)")
        case .chatAction(.editMessageTriggered(let editedMessage)):
            print("ChatReducer `editMessageTriggered` not handled")
        case .chatAction(.editMessageSuccess):
            print("ChatReducer `editMessageSuccess` not handled")
        case .chatAction(.editMessageFailed(let error)):
            print("ChatReducer `editMessageFailed` not handled")
        case .chatAction(.deleteMessageTriggered(let messageId)):
            print("ChatReducer `deleteMessageTriggered` not handled")
        case .chatAction(.deleteMessageSuccess):
            print("ChatReducer `deleteMessageSuccess` not handled")
        case .chatAction(.deleteMessageFailed(let error)):
            print("ChatReducer `deleteMessageFailed` not handled")

        case .chatAction(.sendMessageRetry(let message)):
            print("ChatReducer `sendMessageRetry` not handled")

        // Remote user event received
        case .chatAction(.messageReceived(let newMessage)):
            messagesLastUpdatedTimestamp = Date()
        case .chatAction(.messageEditReceived(let message)):
            print("ChatReducer `messageEditReceived` not handled")
        case .chatAction(.messageDeleteReceived(let message)):
            print("ChatReducer `messageDeleteReceived` not handled")

        case .chatAction(.topicUpdateReceived(let newTopic)):
            // may need to add a message to notifiy topic has been updated
            topic = newTopic

        // ParticipantsAction
        case .participantsAction(.participantsAddedReceived(let participants)):
            messagesLastUpdatedTimestamp = Date()
        case .participantsAction(.participantsRemovedReceived(let participants)):
            messagesLastUpdatedTimestamp = Date()

        default:
            return chatState
        }
        return ChatState(localUser: localUser,
                         topic: topic,
                         messages: messages,
                         messagesLastUpdatedTimestamp: messagesLastUpdatedTimestamp)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatAction: Equatable {

    case chatStartRequested

    // User action
//    case loadInitialMessagesTriggered
    case loadInitialMessagesSuccess(messages: [ChatMessageInfoModel])
    case loadInitialMessagesFailed(error: Error)

    case fetchPreviousMessagesTriggered
    case fetchPreviousMessagesSuccess(messages: [ChatMessageInfoModel])
    case fetchPreviousMessagessFailed(error: Error)

    case sendTypingIndicatorTriggered
    case sendTypingIndicatorSuccess
    case sendTypingIndicatorFailed(error: Error)

    case sendReadReceiptTriggered(messageId: String)
    case sendReadReceiptSuccess
    case sendReadReceiptFailed(error: Error)

    case sendMessageTriggered(message: ChatMessageInfoModel)
    case sendMessageSuccess(message: ChatMessageInfoModel)
    case sendMessageFailed(error: Error)

    case editMessageTriggered(message: ChatMessageInfoModel)
    case editMessageSuccess
    case editMessageFailed(error: Error)

    case deleteMessageTriggered(messageId: String)
    case deleteMessageSuccess
    case deleteMessageFailed(error: Error)

    // Will reuse sendMessageSuccess and sendMessageFailed?
    case sendMessageRetry(message: ChatMessageInfoModel)

    // Remote user event received from ChatSDKEventsHandler
    case messageReceived(message: ChatMessageInfoModel)
    case messageEditReceived(message: ChatMessageInfoModel)
    case messageDeleteReceived(message: ChatMessageInfoModel)

    case topicUpdateReceived(topic: String)

    static func == (lhs: ChatAction, rhs: ChatAction) -> Bool {

        switch (lhs, rhs) {
        case let (.loadInitialMessagesFailed(lErr), .loadInitialMessagesFailed(rErr)),
            let (.fetchPreviousMessagessFailed(lErr), .fetchPreviousMessagessFailed(rErr)),
            let (.sendTypingIndicatorFailed(lErr), .sendTypingIndicatorFailed(rErr)),
            let (.sendReadReceiptFailed(lErr), .sendReadReceiptFailed(rErr)),
            let (.sendMessageFailed(lErr), .sendMessageFailed(rErr)),
            let (.editMessageFailed(lErr), .editMessageFailed(rErr)),
            let (.deleteMessageFailed(lErr), .deleteMessageFailed(rErr)):

            return (lErr as NSError).code == (rErr as NSError).code

        case (.chatStartRequested, .chatStartRequested),
//            (.loadInitialMessagesTriggered, .loadInitialMessagesTriggered),
            (.fetchPreviousMessagesTriggered, .fetchPreviousMessagesTriggered),
            ( .sendTypingIndicatorTriggered, .sendTypingIndicatorTriggered),
            ( .sendTypingIndicatorSuccess, .sendTypingIndicatorSuccess),
            (.sendReadReceiptSuccess, .sendReadReceiptSuccess),
            (.editMessageSuccess, .editMessageSuccess),
            (.deleteMessageSuccess, .deleteMessageSuccess):
            return true

        case let (.sendReadReceiptTriggered(lId), .sendReadReceiptTriggered(rId)),
            let (.deleteMessageTriggered(lId), .deleteMessageTriggered(rId)):
            return lId == rId

        case let (.sendMessageTriggered(lMsg), .sendMessageTriggered(rMsg)),
            let (.sendMessageSuccess(lMsg), .sendMessageSuccess(rMsg)),
            let (.editMessageTriggered(lMsg), .editMessageTriggered(rMsg)),
            let (.sendMessageRetry(lMsg), .sendMessageRetry(rMsg)),
            let (.messageReceived(lMsg), .messageReceived(rMsg)),
            let (.messageEditReceived(lMsg), .messageEditReceived(rMsg)),
            let (.messageDeleteReceived(lMsg), .messageDeleteReceived(rMsg)):
            return lMsg == rMsg

        case let (.topicUpdateReceived(lTopic), .topicUpdateReceived(rTopic)):
            return lTopic == rTopic

        case let (.loadInitialMessagesSuccess(lMsgList), .loadInitialMessagesSuccess(rMsgList)),
            let (.fetchPreviousMessagesSuccess(lMsgList), .fetchPreviousMessagesSuccess(rMsgList)):
            return lMsgList == rMsgList

        default:
            return false
        }
    }
}

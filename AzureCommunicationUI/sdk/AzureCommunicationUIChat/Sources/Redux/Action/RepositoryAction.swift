//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum RepositoryAction: Equatable {

    // MARK: user action send to chat
    case fetchInitialMessagesTriggered
    case fetchInitialMessagesSuccess(messages: [ChatMessageInfoModel])
    case fetchInitialMessagesFailed(error: Error)

    case fetchPreviousMessagesTriggered
    case fetchPreviousMessagesSuccess(messages: [ChatMessageInfoModel])
    case fetchPreviousMessagesFailed(error: Error)

    case sendMessageTriggered(internalId: String,
                              content: String)
    case sendMessageSuccess(internalId: String,
                            actualId: String)
    case sendMessageFailed(internalId: String, error: Error)

    case editMessageTriggered(messageId: String,
                              content: String,
                              prevContent: String)
    case editMessageSuccess(messageId: String)
    case editMessageFailed(messageId: String,
                           prevContent: String,
                           error: Error)

    case deleteMessageTriggered(messageId: String)
    case deleteMessageSuccess(messageId: String)
    case deleteMessageFailed(messageId: String, error: Error)

    case repositoryUpdated

    // MARK: user action receive from chat
    case chatMessageReceived(message: ChatMessageInfoModel)
    case chatMessageEditedReceived(message: ChatMessageInfoModel)
    case chatMessageDeletedReceived(message: ChatMessageInfoModel)

    static func == (lhs: RepositoryAction, rhs: RepositoryAction) -> Bool {
        switch (lhs, rhs) {
        case let (.fetchInitialMessagesFailed(lErr), .fetchInitialMessagesFailed(rErr)),
            let (.fetchPreviousMessagesFailed(lErr), .fetchPreviousMessagesFailed(rErr)):
            return (lErr as NSError).code == (rErr as NSError).code

        case let (.sendMessageFailed(lInternalId, lErr), .sendMessageFailed(rInternalId, rErr)):
            return lInternalId == rInternalId && (lErr as NSError).code == (rErr as NSError).code

        case (.fetchInitialMessagesTriggered, .fetchInitialMessagesTriggered),
            (.fetchPreviousMessagesTriggered, .fetchPreviousMessagesTriggered),
            (.repositoryUpdated, .repositoryUpdated):
            return true

        case let (.fetchInitialMessagesSuccess(lMsgArr), .fetchInitialMessagesSuccess(rMsgArr)),
            let (.fetchPreviousMessagesSuccess(lMsgArr), .fetchPreviousMessagesSuccess(rMsgArr)):
            return lMsgArr == rMsgArr

        case let (.chatMessageReceived(lMsg), .chatMessageReceived(rMsg)),
            let (.chatMessageEditedReceived(lMsg), .chatMessageEditedReceived(rMsg)),
            let (.chatMessageDeletedReceived(lMsg), .chatMessageDeletedReceived(rMsg)):
            return lMsg == rMsg

        default:
            return false
        }
    }
}

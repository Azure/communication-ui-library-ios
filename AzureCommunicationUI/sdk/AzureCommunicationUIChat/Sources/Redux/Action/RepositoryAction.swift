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

    case repositoryUpdated

    // MARK: user action receive from chat
    case chatMessageReceived(message: ChatMessageInfoModel)

    static func == (lhs: RepositoryAction, rhs: RepositoryAction) -> Bool {
        switch (lhs, rhs) {
        case let (.fetchInitialMessagesFailed(lErr), .fetchInitialMessagesFailed(rErr)):
            return (lErr as NSError).code == (rErr as NSError).code

        case (.fetchInitialMessagesTriggered, .fetchInitialMessagesTriggered),
            (.repositoryUpdated, .repositoryUpdated):
            return true

        case let (.fetchInitialMessagesSuccess(lMsgArr), .fetchInitialMessagesSuccess(rMsgArr)):
            return lMsgArr == rMsgArr

        case let (.chatMessageReceived(lMsg), .chatMessageReceived(rMsg)):
            return lMsg == rMsg

        default:
            return false
        }
    }
}

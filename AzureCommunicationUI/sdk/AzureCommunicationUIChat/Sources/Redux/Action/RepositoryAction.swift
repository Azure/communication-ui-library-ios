//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum RepositoryAction: Equatable {
    case fetchInitialMessagesTriggered
    case fetchInitialMessagesSuccess(messages: [ChatMessageInfoModel])
    case fetchInitialMessagesFailed(error: Error)
    case repositoryUpdated

    static func == (lhs: RepositoryAction, rhs: RepositoryAction) -> Bool {
        switch (lhs, rhs) {
        case let (.fetchInitialMessagesFailed(lErr), .fetchInitialMessagesFailed(rErr)):
            return (lErr as NSError).code == (rErr as NSError).code

        case (.fetchInitialMessagesTriggered, .fetchInitialMessagesTriggered),
            (.repositoryUpdated, .repositoryUpdated):
            return true

        case let (.fetchInitialMessagesSuccess(lMsgArr), .fetchInitialMessagesSuccess(rMsgArr)):
            return lMsgArr == rMsgArr

        default:
            return false
        }
    }
}

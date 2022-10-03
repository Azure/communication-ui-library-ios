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

        switch action {
        case .chatAction(.topicUpdated(let newTopic)):
            topic = newTopic
        default:
            return chatState
        }
        return ChatState(localUser: localUser,
                         threadId: threadId,
                         topic: topic)
    }
}

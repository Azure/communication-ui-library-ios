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

        switch action {
        case .chatAction(.chatStartRequested):
            print("ChatReducer `chatStartRequested` not implemented")
        default:
            return chatState
        }
        return ChatState(localUser: localUser)
    }
}

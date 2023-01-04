//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == RepositoryState,
                        Actions == Action {
    static var liveRepositoryReducer: Self = Reducer { repositoryState, action in
        var lastUpdated = repositoryState.lastUpdatedTimestamp
        var hasFetchedInitialMessages = repositoryState.hasFetchedInitialMessages
        var hasFetchedPreviousMessages = repositoryState.hasFetchedPreviousMessages

        switch action {
        case .repositoryAction(.repositoryUpdated):
            lastUpdated = Date()
        case .repositoryAction(.fetchInitialMessagesTriggered):
            hasFetchedInitialMessages = false
        case .repositoryAction(.fetchInitialMessagesSuccess):
            hasFetchedInitialMessages = true
        case .repositoryAction(.fetchPreviousMessagesTriggered):
            hasFetchedPreviousMessages = false
        case .repositoryAction(.fetchPreviousMessagesSuccess):
            hasFetchedPreviousMessages = true
        default:
            return repositoryState
        }
        return RepositoryState(lastUpdatedTimestamp: lastUpdated,
                               hasFetchedInitialMessages: hasFetchedInitialMessages,
                               hasFetchedPreviousMessages: hasFetchedPreviousMessages)
    }
}

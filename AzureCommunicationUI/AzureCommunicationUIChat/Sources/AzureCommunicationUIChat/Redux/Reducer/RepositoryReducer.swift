//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == RepositoryState,
                        Actions == Action {
    static var liveRepositoryReducer: Self = Reducer { repositoryState, action in
        var lastUpdated = repositoryState.lastUpdatedTimestamp

        switch action {
        case .repositoryAction(.repositoryUpdated):
            print("RepositoryAction `repositoryUpdated` not implemented")
        case .repositoryAction(.fetchInitialMessagesSuccess),
                .repositoryAction(.sendMessageTriggered),
                .repositoryAction(.sendMessageSuccess),
                .repositoryAction(.chatMessageReceived):
                lastUpdated = Date()
        default:
            return repositoryState
        }
        return RepositoryState(lastUpdatedTimestamp: lastUpdated)
    }
}

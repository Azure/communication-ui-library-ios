//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == RepositoryState,
                        Actions == Action {
    static var liveRepositoryReducer: Self = Reducer { repositoryState, action in

        switch action {
        case .repositoryAction(.repositoryUpdated):
            print("RepositoryAction `repositoryUpdated` not implemented")
        default:
            return repositoryState
        }
        return RepositoryState()
    }
}

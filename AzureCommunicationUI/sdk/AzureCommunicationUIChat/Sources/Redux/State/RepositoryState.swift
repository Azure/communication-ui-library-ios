//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct RepositoryState {
    let lastUpdatedTimestamp: Date
    let hasFetchedInitialMessages: Bool
    let hasFetchedPreviousMessages: Bool

    init(lastUpdatedTimestamp: Date = Date(),
         hasFetchedInitialMessages: Bool = false,
         hasFetchedPreviousMessages: Bool = true) {
        self.lastUpdatedTimestamp = lastUpdatedTimestamp
        self.hasFetchedInitialMessages = hasFetchedInitialMessages
        self.hasFetchedPreviousMessages = hasFetchedPreviousMessages
    }
}

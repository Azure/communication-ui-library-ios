//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct RepositoryState {
    let lastUpdatedTimestamp: Date
    let hasFetchedInitialMessages: Bool
    let hasFetchedPreviousMessages: Bool
    let hasExhaustedPreviousMessages: Bool

    init(lastUpdatedTimestamp: Date = Date(),
         hasFetchedInitialMessages: Bool = false,
         hasFetchedPreviousMessages: Bool = true,
         hasExhaustedPreviousMessages: Bool = false) {
        self.lastUpdatedTimestamp = lastUpdatedTimestamp
        self.hasFetchedInitialMessages = hasFetchedInitialMessages
        self.hasFetchedPreviousMessages = hasFetchedPreviousMessages
        self.hasExhaustedPreviousMessages = hasExhaustedPreviousMessages
    }
}

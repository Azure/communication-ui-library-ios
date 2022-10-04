//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct RepositoryState {
    let lastUpdatedTimestamp: Date

    init(lastUpdatedTimestamp: Date = Date()) {
        self.lastUpdatedTimestamp = lastUpdatedTimestamp
    }
}

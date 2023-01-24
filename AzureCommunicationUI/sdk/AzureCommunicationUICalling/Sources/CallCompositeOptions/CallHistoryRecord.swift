//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Call history.
public struct CallHistoryRecord {

    /// Local date call started on.
    public let callStartedOn: Date

    /// Call Ids associated with particular call.
    public let callIdList: [String]

    init(callStartedOn: Date, callIdList: [String]) {
        self.callStartedOn = callStartedOn
        self.callIdList = callIdList
    }
}

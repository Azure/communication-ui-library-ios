//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Call history.
public struct CallHistoryRecord {

    /// Device-generated timestamp for the call start.
    public let callStartedOn: Date

    /// Call Ids associated with particular call started on callStartedOn date.
    public let callIds: [String]

    init(callStartedOn: Date, callIds: [String]) {
        self.callStartedOn = callStartedOn
        self.callIds = callIds
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A Call Composite debug information.
public struct DebugInfo {
    /// The history of calls up to 30 days. Ordered ascending by call started date.
    public let callHistoryRecords: [CallHistoryRecord]

    /// Call history.
    init(callHistoryRecords: [CallHistoryRecord]) {
        self.callHistoryRecords = callHistoryRecords
    }
}

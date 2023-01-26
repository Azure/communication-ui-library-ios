//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A Call Composite debug information.
public struct DebugInfo {
    /// The current or last known call id for the current CallComposite object.
    public let callHistoryRecordList: [CallHistoryRecord]

    /// Call history.
    init(callHistoryRecordList: [CallHistoryRecord]) {
        self.callHistoryRecordList = callHistoryRecordList
    }
}

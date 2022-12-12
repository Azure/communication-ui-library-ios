//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A Call Composite debug information.
public struct DebugInfo {
    /// The current or last known call id for the current CallComposite object.
    /// `Nil` is returned if a call hasn't started for CallComposite.
    public let currentOrLastCallId: String?

    init(lastCallId: String? = nil) {
        self.currentOrLastCallId = lastCallId
    }
}

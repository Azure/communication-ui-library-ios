//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A Call Composite debug information.
public struct DebugInfo {
    /// The last known call id for CallComposite object.
    /// `Nil` is returned if a call hasn't started for CallComposite.
    public let lastCallId: String?

    init(lastCallId: String? = nil) {
        self.lastCallId = lastCallId
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating CallScreenControlBar.
public struct CallScreenControlBarOptions {
    /// Disable the leave call confirmation.
    public let disableLeaveCallConfirmation: Bool

    /// Creates an instance of CallScreenControlBarOptions.
    /// - Parameter disableLeaveCallConfirmation: disable the leave call confirmation.
    init(disableLeaveCallConfirmation: Bool = false) {
        self.disableLeaveCallConfirmation = disableLeaveCallConfirmation
    }
}

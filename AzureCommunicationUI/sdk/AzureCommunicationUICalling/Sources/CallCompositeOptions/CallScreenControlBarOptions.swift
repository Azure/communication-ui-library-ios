//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating CallScreenControlBar.
public struct CallScreenControlBarOptions {
    /// Hide the leave call confirm dialog.
    public let hideLeaveCallConfirmDialog: Bool

    /// Creates an instance of CallScreenControlBarOptions.
    /// - Parameter hideLeaveCallConfirmDialog: Hide the leave call confirm dialog.
    init(hideLeaveCallConfirmDialog: Bool = false) {
        self.hideLeaveCallConfirmDialog = hideLeaveCallConfirmDialog
    }
}

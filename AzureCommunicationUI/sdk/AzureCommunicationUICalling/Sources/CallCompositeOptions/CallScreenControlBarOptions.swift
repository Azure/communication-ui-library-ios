//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Configuration options for customizing the call screen control bar.
public struct CallScreenControlBarOptions {
    /// Determines whether to display leave call confirmation. Default is enabled.
    public let leaveCallConfirmationMode: LeaveCallConfirmationMode

    /// Initializes an instance of CallScreenControlBarOptions.
    /// - Parameter leaveCallConfirmationMode: Whether to enable or disable the leave call confirmation.
    ///                                           Default is enabled.
    public init(leaveCallConfirmationMode: LeaveCallConfirmationMode = .alwaysEnabled) {
        self.leaveCallConfirmationMode = leaveCallConfirmationMode
    }
}

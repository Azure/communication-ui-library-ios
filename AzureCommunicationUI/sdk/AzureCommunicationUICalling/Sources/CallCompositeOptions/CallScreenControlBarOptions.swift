//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Configuration options for customizing the CallScreenControlBar.
public struct CallScreenControlBarOptions {
    /// Determines whether to display leave call confirmation. Default is enabled.
    public let leaveCallConfirmation: CallCompositeLeaveCallConfirmation

    /// Initializes an instance of CallScreenControlBarOptions.
    /// - Parameter leaveCallConfirmation: Whether to enable or disable the leave call confirmation. Default is enabled.
    init(leaveCallConfirmation: CallCompositeLeaveCallConfirmation = .enable) {
        self.leaveCallConfirmation = leaveCallConfirmation
    }
}

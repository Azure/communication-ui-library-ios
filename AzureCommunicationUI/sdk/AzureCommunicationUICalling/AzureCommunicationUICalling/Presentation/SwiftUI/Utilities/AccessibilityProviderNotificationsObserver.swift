//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc
protocol AccessibilityProviderNotificationsObserver {
    /// Function will be executed when receiving a notification.
    /// The notification may be sent a couple of times for the same value
    func didChangeVoiceOverStatus(_ notification: NSNotification)

    func didUIFocusUpdateNotification(_ notification: NSNotification)
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc
protocol AccessibilityProviderNotificationsObserver {
    /// Function will be executed when receiving a notification
    func didChangeVoiceOverStatus(_ notification: NSNotification)
}

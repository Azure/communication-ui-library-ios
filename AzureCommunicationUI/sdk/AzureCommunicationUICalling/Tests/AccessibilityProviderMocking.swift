//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
@testable import AzureCommunicationUICalling

class AccessibilityProviderMocking: AccessibilityProviderProtocol {

    var postQueuedAnnouncementBlock: ((String) -> Void)?
    var moveFocusToFirstElementBlock: (() -> Void)?
    var moveFocusToViewBlock: ((UIView) -> Void)?
    var subscribeToVoiceOverStatusDidChangeNotificationBlock: ((AccessibilityProviderNotificationsObserver) -> Void)?
    var subscribeToUIFocusDidUpdateNotificationBlock: ((AccessibilityProviderNotificationsObserver) -> Void)?

    var isVoiceOverEnabled: Bool = false

    func postQueuedAnnouncement(_ announcement: String) {
        postQueuedAnnouncementBlock?(announcement)
    }

    func moveFocusToFirstElement() {
        moveFocusToFirstElementBlock?()
    }

    func moveFocusToView(_ view: UIView) {
        moveFocusToViewBlock?(view)
    }

    func subscribeToVoiceOverStatusDidChangeNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        subscribeToVoiceOverStatusDidChangeNotificationBlock?(observer)
    }

    func subscribeToUIFocusDidUpdateNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        subscribeToUIFocusDidUpdateNotificationBlock?(observer)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class AccessibilityProviderMocking: AccessibilityProviderProtocol {
    var postQueuedAnnouncementBlock: ((String) -> Void)?
    var moveFocusToFirstElementBlock: (() -> Void)?
    var subscribeToVoiceOverStatusDidChangeNotificationBlock: ((AccessibilityProviderNotificationsObserver) -> Void)?

    var isVoiceOverEnabled: Bool = false

    func postQueuedAnnouncement(_ announcement: String) {
        postQueuedAnnouncementBlock?(announcement)
    }

    func moveFocusToFirstElement() {
        moveFocusToFirstElementBlock?()
    }

    func subscribeToVoiceOverStatusDidChangeNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        subscribeToVoiceOverStatusDidChangeNotificationBlock?(observer)
    }
}

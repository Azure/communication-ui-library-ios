//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

protocol AccessibilityProviderProtocol {
    /// A Boolean value that indicates whether VoiceOver is in an enabled state
    var isVoiceOverEnabled: Bool { get }

    /// Post an announcement as NSAttributedString with accessibilitySpeechQueueAnnouncement set to true
    /// - Parameter announcement: Message to announce
    func postQueuedAnnouncement(_ announcement: String)

    /// Move focus to the element with the highest sort priority for the current view
    func moveFocusToFirstElement()

    /// Add observer for voiceOverStatusDidChangeNotification
    /// - Parameter completion: completion that will be executed when receiving a notification
    func subscribeToVoiceOverStatusDidChangeNotification(_ observer: AccessibilityProviderNotificationsObserver)
}

struct AccessibilityProvider: AccessibilityProviderProtocol {
    var isVoiceOverEnabled: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    func postQueuedAnnouncement(_ announcement: String) {
        let message = NSAttributedString(string: announcement,
                                         attributes: [.accessibilitySpeechQueueAnnouncement: true])
        UIAccessibility.post(notification: .announcement,
                             argument: message)
    }

    func moveFocusToFirstElement() {
        UIAccessibility.post(notification: .screenChanged,
                             argument: nil)
    }

    func subscribeToVoiceOverStatusDidChangeNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        let selector = #selector(AccessibilityProviderNotificationsObserver.didChangeVoiceOverStatus)
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                               object: nil)
    }
}

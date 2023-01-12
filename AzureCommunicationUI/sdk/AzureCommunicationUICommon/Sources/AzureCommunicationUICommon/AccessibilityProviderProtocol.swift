//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

protocol AccessibilityProviderProtocol {
    /// A Boolean value that indicates whether VoiceOver is in an enabled state
    var isVoiceOverEnabled: Bool { get }

    /// Post an announcement as NSAttributedString with accessibilitySpeechQueueAnnouncement set to true
    /// - Parameter announcement: Message to announce
    func postQueuedAnnouncement(_ announcement: String)

    /// Move focus to the element with the highest sort priority for the current view
    func moveFocusToFirstElement()

    /// Moves focus to the view
    /// - Parameter view: The UIView that will be focused
    func moveFocusToView(_ view: UIView)

    /// Add observer for voiceOverStatusDidChangeNotification
    /// - Parameter completion: completion that will be executed when receiving a notification
    func subscribeToVoiceOverStatusDidChangeNotification(_ observer: AccessibilityProviderNotificationsObserver)

    /// Add observer for UIFocusDidUpdateNotification
    /// - Parameter completion: completion that will be executed when receiving a notification
    func subscribeToUIFocusDidUpdateNotification(_ observer: AccessibilityProviderNotificationsObserver)
}

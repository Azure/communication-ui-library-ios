//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

@_spi(common) public protocol AccessibilityProviderProtocol {
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

    /// Add observer for UIFocusDidUpdateNotification
    /// - Parameter completion: completion that will be executed when receiving a notification
    func subscribeToUIFocusDidUpdateNotification(_ observer: AccessibilityProviderNotificationsObserver)
}

@_spi(common) public struct AccessibilityProvider: AccessibilityProviderProtocol {

    public init() { }
    
    public var isVoiceOverEnabled: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    public func postQueuedAnnouncement(_ announcement: String) {
        let message = NSAttributedString(string: announcement,
                                         attributes: [.accessibilitySpeechQueueAnnouncement: true])
        UIAccessibility.post(notification: .announcement,
                             argument: message)
    }

    public func moveFocusToFirstElement() {
        UIAccessibility.post(notification: .screenChanged,
                             argument: nil)
    }

    public func subscribeToVoiceOverStatusDidChangeNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        let selector = #selector(AccessibilityProviderNotificationsObserver.didChangeVoiceOverStatus)
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                               object: nil)
    }

    public func subscribeToUIFocusDidUpdateNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        let selector = #selector(AccessibilityProviderNotificationsObserver.didUIFocusUpdateNotification)
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: UIFocusSystem.didUpdateNotification,
                                               object: nil)
    }
}

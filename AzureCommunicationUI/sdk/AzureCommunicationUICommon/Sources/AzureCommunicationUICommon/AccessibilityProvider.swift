//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

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

    func moveFocusToView(_ view: UIView) {
        UIAccessibility.post(notification: .layoutChanged,
                             argument: view)
    }

    func subscribeToVoiceOverStatusDidChangeNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        let selector = #selector(AccessibilityProviderNotificationsObserver.didChangeVoiceOverStatus)
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                               object: nil)
    }

    func subscribeToUIFocusDidUpdateNotification(_ observer: AccessibilityProviderNotificationsObserver) {
        let selector = #selector(AccessibilityProviderNotificationsObserver.didUIFocusUpdateNotification)
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: UIFocusSystem.didUpdateNotification,
                                               object: nil)
    }
}
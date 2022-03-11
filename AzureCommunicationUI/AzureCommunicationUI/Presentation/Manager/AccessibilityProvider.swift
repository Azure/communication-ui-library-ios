//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

struct AccessibilityProvider {
    /// Post an announcement as NSAttributedString with accessibilitySpeechQueueAnnouncement set to true
    /// - Parameter announcement: Message to announce
    static func postQueuedAnnouncement(_ announcement: String) {
        let message = NSAttributedString(string: announcement,
                                         attributes: [.accessibilitySpeechQueueAnnouncement: true])
        UIAccessibility.post(notification: .announcement,
                             argument: message)
    }

    /// Move focus to the element with the highest sort priority for the current view
    static func moveFocusToFirstElement() {
        UIAccessibility.post(notification: .screenChanged,
                             argument: nil)
    }
}

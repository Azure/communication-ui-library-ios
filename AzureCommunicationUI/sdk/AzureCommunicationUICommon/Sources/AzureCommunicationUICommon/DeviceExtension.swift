//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

extension UIDevice {

    /// Returns `true` if the device has a home bar in landscape
    var hasHomeBar: Bool {
        guard let window =
            UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        else {
            return false
        }

        return window.safeAreaInsets.bottom > 0
    }

    func toggleProximityMonitoringStatus(isEnabled: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = isEnabled
    }
    func rotateTo(orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

extension UIScreen {
    static func isScreenSmall(_ length: CGFloat) -> Bool {
        let maxLength = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return maxLength < length
    }
}

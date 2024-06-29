//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

protocol DrawerViewControllerProtocol {
    func resetOrientation()
}

extension DrawerViewControllerProtocol where Self: UIViewController {
    func resetOrientation() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIDevice.current.orientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

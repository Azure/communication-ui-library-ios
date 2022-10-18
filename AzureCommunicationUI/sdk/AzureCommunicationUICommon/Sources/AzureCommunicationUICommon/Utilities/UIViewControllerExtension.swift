//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

@_spi(common) public extension UIViewController {

    func dismissSelf(completion: (() -> Void)? = nil) {
        if let presentingVc = presentingViewController {
            view.endEditing(true)
            presentingVc.dismiss(animated: true, completion: completion)
        }
    }
}

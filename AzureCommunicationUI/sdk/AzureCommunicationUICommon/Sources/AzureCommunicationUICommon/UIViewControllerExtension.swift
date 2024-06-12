//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

extension UIViewController {
    func dismissSelf(completion: (() -> Void)? = nil, animated: Bool = true) {
        view.endEditing(true)
        if let presentingVc = presentingViewController {
            presentingVc.dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
}

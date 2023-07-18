//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

extension UIViewController {

    func dismissSelf(completion: (() -> Void)? = nil, animated: Bool = true) {
        if let presentingVc = presentingViewController {
            view.endEditing(true)
            presentingVc.dismiss(animated: animated, completion: completion)
        }
    }
}

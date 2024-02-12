//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

internal func captureScreenshot() -> UIImage? {
    guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    else { return nil }
    UIGraphicsBeginImageContext(window.frame.size)
    window.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

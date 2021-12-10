//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public protocol ThemeConfiguration {
    var primaryColor: UIColor { get }
}

public extension ThemeConfiguration {
    var primaryColor: UIColor {
        return UIColor.compositeColor(.primary)
    }
}

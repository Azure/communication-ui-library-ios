//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import FluentUI

class ThemeColor: ThemeOptions {
    var colorSchemeOverride: UIUserInterfaceStyle {
        return .unspecified
    }
    var primaryColor: UIColor {
        return StyleProvider.color.brandBackground1
    }
    var primaryColorTint10: UIColor {
        return StyleProvider.color.brandBackground1
    }
    var primaryColorTint20: UIColor {
        return StyleProvider.color.brandBackground1
    }
    var primaryColorTint30: UIColor {
        return StyleProvider.color.brandBackground1
    }
    /* <CUSTOM_COLOR_FEATURE> */
    var foregroundOnPrimaryColor: UIColor {
        return StyleProvider.color.brandBackground1
    }
}

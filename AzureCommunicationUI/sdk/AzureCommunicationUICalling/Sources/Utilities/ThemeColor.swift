//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import FluentUI

struct ThemeColor: ThemeOptions {
    init() {
    }
    var colorSchemeOverride: UIUserInterfaceStyle {
        return .unspecified
    }
    var primaryColor: UIColor {
        return Colors.Palette.communicationBlue.color
    }
    var primaryColorTint10: UIColor {
        return Colors.Palette.communicationBlueTint10.color
    }
    var primaryColorTint20: UIColor {
        return Colors.Palette.communicationBlueTint20.color
    }
    var primaryColorTint30: UIColor {
        return Colors.Palette.communicationBlueTint30.color
    }
    /* <CUSTOM_COLOR_FEATURE> */
    var foregroundOnPrimaryColor: UIColor {
        return .white
    }
}

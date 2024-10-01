//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import FluentUI
import UIKit
import AzureCommunicationUICalling

struct MockThemeOptions: ThemeOptions {
    var colorSchemeOverride: UIUserInterfaceStyle
    var primaryColor: UIColor
    var primaryColorTint10: UIColor
    var primaryColorTint20: UIColor
    var primaryColorTint30: UIColor
    var foregroundOnPrimaryColor: UIColor
    // Default initializer for convenience
    init(
        colorSchemeOverride: UIUserInterfaceStyle = .unspecified,
        primaryColor: UIColor = Colors.Palette.communicationBlue.color,
        primaryColorTint10: UIColor = Colors.Palette.communicationBlueTint10.color,
        primaryColorTint20: UIColor = Colors.Palette.communicationBlueTint20.color,
        primaryColorTint30: UIColor = Colors.Palette.communicationBlueTint30.color,
        foregroundOnPrimaryColor: UIColor = .white
    ) {
        self.colorSchemeOverride = colorSchemeOverride
        self.primaryColor = primaryColor
        self.primaryColorTint10 = primaryColorTint10
        self.primaryColorTint20 = primaryColorTint20
        self.primaryColorTint30 = primaryColorTint30
        self.foregroundOnPrimaryColor = foregroundOnPrimaryColor
    }
}

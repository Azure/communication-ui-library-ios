//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class ColorThemeProvider {
    let colorSchemeOverride: UIUserInterfaceStyle

    let primaryColor: UIColor
    let primaryColorTint10: UIColor
    let primaryColorTint20: UIColor
    let primaryColorTint30: UIColor

    let textDominant: UIColor = Colors.textDominant
    let textPrimary: UIColor = Colors.textPrimary
    let textSecondary: UIColor = Colors.textSecondary
    let textDisabled: UIColor = Colors.textDisabled
    let surfaceTertiary: UIColor = Colors.surfaceTertiary
    let dividerOnPrimary: UIColor = Colors.dividerOnPrimary
    let iconSecondary: UIColor = Colors.iconSecondary
    let iconDisabled: UIColor = Colors.iconDisabled

    let dangerPrimary: UIColor = Colors.error

    init(themeOptions: ThemeOptions?) {
        self.colorSchemeOverride = themeOptions?.colorSchemeOverride ?? .unspecified

        self.primaryColor = themeOptions?.primaryColor ?? Colors.Palette.communicationBlue.color
        self.primaryColorTint10 = themeOptions?.primaryColorTint10 ?? Colors.Palette.communicationBlueTint10.color
        self.primaryColorTint20 = themeOptions?.primaryColorTint20 ?? Colors.Palette.communicationBlueTint20.color
        self.primaryColorTint30 = themeOptions?.primaryColorTint30 ?? Colors.Palette.communicationBlueTint30.color
    }

    private func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

extension ColorThemeProvider: ColorProviding {
    func primaryColor(for window: UIWindow) -> UIColor? {
        return primaryColor
    }

    func primaryTint10Color(for window: UIWindow) -> UIColor? {
        return primaryColorTint10
    }

    func primaryTint20Color(for window: UIWindow) -> UIColor? {
        return primaryColorTint20
    }

    func primaryTint30Color(for window: UIWindow) -> UIColor? {
        return primaryColorTint30
    }

    func primaryTint40Color(for window: UIWindow) -> UIColor? {
        return primaryColor
    }

    func primaryShade10Color(for window: UIWindow) -> UIColor? {
        return primaryColor
    }

    func primaryShade20Color(for window: UIWindow) -> UIColor? {
        return primaryColor
    }

    func primaryShade30Color(for window: UIWindow) -> UIColor? {
        return primaryColor
    }
}

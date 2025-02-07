//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit
import SwiftUICore

class ColorThemeProvider {
    let fluentTheme = FluentTheme()
    let colorSchemeOverride: UIUserInterfaceStyle

//    let primaryColor: UIColor
//    let primaryColorTint10: UIColor
//    let primaryColorTint20: UIColor
//    let primaryColorTint30: UIColor

//    let textDominant: UIColor = Colors.textDominant
//    let textPrimary: UIColor = Colors.textPrimary
//    let textSecondary: UIColor = Colors.textSecondary
//    let textDisabled: UIColor = Colors.textDisabled
//    let surfaceTertiary: UIColor = Colors.surfaceTertiary
//    let dividerOnPrimary: UIColor = Colors.dividerOnPrimary
//    let iconSecondary: UIColor = Colors.iconSecondary
//    let iconDisabled: UIColor = Colors.iconDisabled\
//    let dangerPrimary: UIColor // = Colors.error

    let foreground1: Color
    let foreground2: Color
    let foreground3: Color
    let foregroundDisabled1: Color
    let stroke2: Color
    let severeBackground1: Color

    init(themeOptions: ThemeOptions?) {
        self.colorSchemeOverride = themeOptions?.colorSchemeOverride ?? .unspecified

//        self.primaryColor = themeOptions?.primaryColor ?? Colors.Palette.communicationBlue.color
//        self.primaryColorTint10 = themeOptions?.primaryColorTint10 ?? Colors.Palette.communicationBlueTint10.color
//        self.primaryColorTint20 = themeOptions?.primaryColorTint20 ?? Colors.Palette.communicationBlueTint20.color
//        self.primaryColorTint30 = themeOptions?.primaryColorTint30 ?? Colors.Palette.communicationBlueTint30.color

        self.foreground1 = fluentTheme.swiftUIColor(.foreground1) // F1: textDominant
        self.foreground2 = fluentTheme.swiftUIColor(.foreground2) // F1: textSecondary?
        self.foreground3 = fluentTheme.swiftUIColor(.foreground3) // F1: iconSecondary?
        self.foregroundDisabled1 = fluentTheme.swiftUIColor(.foregroundDisabled1) // F1: iconDisabled
        self.stroke2 = fluentTheme.swiftUIColor(.stroke2) // F1: dividerOnPrimary
        self.severeBackground1 = fluentTheme.swiftUIColor(.severeBackground1) // F1: dangerPrimary?
    }

    private func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

extension ColorThemeProvider: ColorProviding {
    var brandBackground1: UIColor {
        return fluentTheme.color(.brandBackground1)
    }
    var brandBackground1Pressed: UIColor {
        return fluentTheme.color(.brandBackground1Pressed)
    }
    var brandBackground1Selected: UIColor {
        return fluentTheme.color(.brandBackground1Selected)
    }
    var brandBackground2: UIColor {
        return fluentTheme.color(.brandBackground2)
    }
    var brandBackground2Pressed: UIColor {
        return fluentTheme.color(.brandBackground2Pressed)
    }
    var brandBackground2Selected: UIColor {
        return fluentTheme.color(.brandBackground2Selected)
    }
    var brandBackground3: UIColor {
        return fluentTheme.color(.background3)
    }
    var brandBackgroundTint: UIColor {
        return fluentTheme.color(.brandBackgroundTint)
    }
    var brandBackgroundDisabled: UIColor {
        return fluentTheme.color(.brandBackgroundDisabled)
    }
    var brandForeground1: UIColor {
        return fluentTheme.color(.brandForeground1)
    }
    var brandForeground1Pressed: UIColor {
        return fluentTheme.color(.brandForeground1Pressed)
    }
    var brandForeground1Selected: UIColor {
        return fluentTheme.color(.brandForeground1Selected)
    }
    var brandForegroundTint: UIColor {
        return fluentTheme.color(.brandForegroundTint)
    }
    var brandForegroundDisabled1: UIColor {
        return fluentTheme.color(.brandForegroundDisabled1)
    }
    var brandForegroundDisabled2: UIColor {
        return fluentTheme.color(.brandForegroundDisabled2)
    }
    var brandStroke1: UIColor {
        return fluentTheme.color(.brandStroke1)
    }
    var brandStroke1Pressed: UIColor {
        return fluentTheme.color(.brandStroke1Pressed)
    }
    var brandStroke1Selected: UIColor {
        return fluentTheme.color(.brandStroke1Selected)
    }
//    func primaryColor(for window: UIWindow) -> UIColor? {
//        return primaryColor
//    }
//
//    func primaryTint10Color(for window: UIWindow) -> UIColor? {
//        return primaryColorTint10
//    }
//
//    func primaryTint20Color(for window: UIWindow) -> UIColor? {
//        return primaryColorTint20
//    }
//
//    func primaryTint30Color(for window: UIWindow) -> UIColor? {
//        return primaryColorTint30
//    }
//
//    func primaryTint40Color(for window: UIWindow) -> UIColor? {
//        return primaryColor
//    }
//
//    func primaryShade10Color(for window: UIWindow) -> UIColor? {
//        return primaryColor
//    }
//
//    func primaryShade20Color(for window: UIWindow) -> UIColor? {
//        return primaryColor
//    }
//
//    func primaryShade30Color(for window: UIWindow) -> UIColor? {
//        return primaryColor
//    }
}

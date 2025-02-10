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
//    /* <CUSTOM_COLOR_FEATURE> */
//    let foregroundOnPrimaryColor: UIColor
//    /* </CUSTOM_COLOR_FEATURE> */
//    // MARK: Text Label Colours
//    let textSecondary: UIColor = Colors.textSecondary
//
//    lazy var onWarning: UIColor = {
//        return dynamicColor(light: Colors.Palette.warningShade30.color,
//                            dark: Colors.surfacePrimary)
//    }()
//    let onHoldBackground = UIColor.compositeColor(.onHoldBackground)
//    lazy var onError: UIColor = {
//        return dynamicColor(light: Colors.surfacePrimary,
//                            dark: Colors.surfaceSecondary)
//    }()
//    lazy var onPrimary: UIColor = {
//        return dynamicColor(light: Colors.surfacePrimary,
//                            dark: Colors.surfaceSecondary)
//    }()
//    lazy var onSuccess: UIColor = {
//        return dynamicColor(light: Colors.surfacePrimary,
//                            dark: Colors.surfaceSecondary)
//    }()
//    lazy var onSurface: UIColor = {
//        return dynamicColor(light: Colors.Palette.gray950.color,
//                            dark: Colors.textDominant)
//    }()
//    lazy var onBackground: UIColor = {
//        return dynamicColor(light: Colors.Palette.gray950.color,
//                            dark: Colors.textDominant)
//    }()
//    lazy var onSurfaceColor: UIColor = {
//        return dynamicColor(light: Colors.Palette.gray950.color,
//                            dark: Colors.textDominant)
//    }()
//    lazy var onNavigationSecondary: UIColor = {
//        return dynamicColor(light: Colors.textSecondary,
//                            dark: Colors.textDominant)
//    }()

//    // MARK: - Button Icon Colours
//    let hangup = UIColor.compositeColor(.hangup)
//    let disableColor: UIColor = Colors.iconDisabled
//    let drawerIconDark: UIColor = Colors.iconSecondary
//
//    // MARK: - View Background Colours
//    let error: UIColor = Colors.error
//    let success: UIColor = Colors.Palette.successPrimary.color
//    lazy var warning: UIColor = {
//        return dynamicColor(light: Colors.Palette.warningTint40.color,
//                            dark: Colors.warning)
//    }()
//    let overlay = UIColor.compositeColor(.overlay)
//    let gridLayoutBackground: UIColor = Colors.surfacePrimary
//    let gradientColor = UIColor.black.withAlphaComponent(0.7)
//    let surfaceDarkColor = UIColor.black.withAlphaComponent(0.6)
//    let surfaceLightColor = UIColor.black.withAlphaComponent(0.3)
//    lazy var backgroundColor: UIColor = {
//        return dynamicColor(light: Colors.surfacePrimary,
//                            dark: Colors.surfaceSecondary)
//    }()
//    lazy var drawerColor: UIColor = {
//        return dynamicColor(light: Colors.surfacePrimary,
//                            dark: Colors.Palette.gray900.color)
//    }()
//    lazy var popoverColor: UIColor = {
//        return dynamicColor(light: Colors.surfacePrimary,
//                            dark: Colors.surfaceQuaternary)
//    }()
//    lazy var surface: UIColor = {
//        return dynamicColor(light: Colors.surfaceQuaternary,
//                            dark: Colors.Palette.gray800.color)
//    }()

    let surfaceDarkColor: UIColor
    let drawerColor: UIColor
    let surface: UIColor
    let onHoldBackground: UIColor
    let backgroundColor: UIColor
    let warning: UIColor
    let onWarning: UIColor
    let gridLayoutBackground: UIColor
    let disableColor: UIColor
    let overlay: UIColor
    let textSecondary: UIColor
    let hangup: UIColor
    let surfaceLightColor: UIColor
    let onSurface: UIColor
    let onSurfaceColor: UIColor
    let onBackground: UIColor
    let onNavigationSecondary: UIColor
    let gradientColor: UIColor

    init(themeOptions: ThemeOptions?) {
        self.colorSchemeOverride = themeOptions?.colorSchemeOverride ?? .unspecified

        // self.primaryColor = themeOptions?.primaryColor ?? Colors.Palette.communicationBlue.color
        // self.primaryColorTint10 = themeOptions?.primaryColorTint10 ?? Colors.Palette.communicationBlueTint10.color
        // self.primaryColorTint20 = themeOptions?.primaryColorTint20 ?? Colors.Palette.communicationBlueTint20.color
        // self.primaryColorTint30 = themeOptions?.primaryColorTint30 ?? Colors.Palette.communicationBlueTint30.color
        //        /* <CUSTOM_COLOR_FEATURE> */
        // self.foregroundOnPrimaryColor = themeOptions?.foregroundOnPrimaryColor ?? .orange
        //        /* </CUSTOM_COLOR_FEATURE> */

        // Search and replace to put correct names in code

        self.surfaceDarkColor = UIColor.black.withAlphaComponent(0.6) // Replace with Fluent
        self.drawerColor = fluentTheme.color(.background1)
        self.surface = fluentTheme.color(.background4)
        self.onHoldBackground = UIColor.compositeColor(.onHoldBackground) // Replace with fluent
        self.backgroundColor = fluentTheme.color(.background1) // Double check dark mode
        self.warning = fluentTheme.color(.dangerBackground1) // Double check
        self.onWarning = fluentTheme.color(.dangerForeground1) // Double check
        self.gridLayoutBackground = fluentTheme.color(.background1) // Duplicate?
        self.disableColor = fluentTheme.color(.foregroundDisabled1) // Double check
        self.overlay = UIColor.compositeColor(.overlay) // Replace with Fluent
        self.textSecondary = fluentTheme.color(.foreground2) // Double check
        self.hangup = UIColor.compositeColor(.hangup) // Replace with Fluent
        self.surfaceLightColor = UIColor.black.withAlphaComponent(0.3) // Replace with Fluent
        self.onSurface = fluentTheme.color(.foreground2) // Double check
        self.onSurfaceColor = fluentTheme.color(.foreground2) // Duplicate
        self.onBackground = fluentTheme.color(.foreground2) // Duplicate
        self.onNavigationSecondary = fluentTheme.color(.foreground2) // Double Check
        self.gradientColor = UIColor.black.withAlphaComponent(0.7) // Replace with Fluent
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
//    /* <CUSTOM_COLOR_FEATURE> */
//    func foregroundOnPrimaryColor(for window: UIWindow) -> UIColor? {
//        return foregroundOnPrimaryColor
//    }
//    /* </CUSTOM_COLOR_FEATURE> */
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

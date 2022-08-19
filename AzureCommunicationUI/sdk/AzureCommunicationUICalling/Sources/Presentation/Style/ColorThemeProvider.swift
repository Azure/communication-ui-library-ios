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

    // MARK: Text Label Colours
    let onHoldLabel: UIColor = Colors.textSecondary
    let onWarning: UIColor = Colors.Palette.gray950.color
    let onHoldBackground = UIColor.compositeColor(.onHoldBackground)
    lazy var onError: UIColor = {
        return dynamicColor(light: Colors.surfacePrimary,
                            dark: Colors.surfaceSecondary)
    }()
    lazy var onPrimary: UIColor = {
        return dynamicColor(light: Colors.surfacePrimary,
                            dark: Colors.surfaceSecondary)
    }()
    lazy var onSuccess: UIColor = {
        return dynamicColor(light: Colors.surfacePrimary,
                            dark: Colors.surfaceSecondary)
    }()
    lazy var onSurface: UIColor = {
        return dynamicColor(light: Colors.Palette.gray950.color,
                            dark: Colors.textDominant)
    }()
    lazy var onBackground: UIColor = {
        return dynamicColor(light: Colors.Palette.gray950.color,
                            dark: Colors.textDominant)
    }()
    lazy var onSurfaceColor: UIColor = {
        return dynamicColor(light: Colors.Palette.gray950.color,
                            dark: Colors.textDominant)
    }()
    lazy var onNavigationSecondary: UIColor = {
        return dynamicColor(light: Colors.textSecondary,
                            dark: Colors.textDominant)
    }()

    // MARK: - Button Icon Colours
    let error: UIColor = Colors.error
    let warning: UIColor = Colors.warning
    let hangup = UIColor.compositeColor(.hangup)
    let disableColor: UIColor = Colors.iconDisabled
    let drawerIconDark: UIColor = Colors.iconSecondary
    let success: UIColor = Colors.Palette.successPrimary.color

    // MARK: - View Background Colours
    let overlay = UIColor.compositeColor(.overlay)
    let gridLayoutBackground: UIColor = Colors.surfacePrimary
    let gradientColor = UIColor.black.withAlphaComponent(0.7)
    let surfaceDarkColor = UIColor.black.withAlphaComponent(0.6)
    let surfaceLightColor = UIColor.black.withAlphaComponent(0.3)
    lazy var backgroundColor: UIColor = {
        return dynamicColor(light: Colors.surfacePrimary,
                            dark: Colors.surfaceSecondary)
    }()
    lazy var drawerColor: UIColor = {
        return dynamicColor(light: Colors.surfacePrimary,
                            dark: Colors.Palette.gray900.color)
    }()
    lazy var popoverColor: UIColor = {
        return dynamicColor(light: Colors.surfacePrimary,
                            dark: Colors.surfaceQuaternary)
    }()
    lazy var surface: UIColor = {
        return dynamicColor(light: Colors.surfaceQuaternary,
                            dark: Colors.Palette.gray800.color)
    }()

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

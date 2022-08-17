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

    // MARK: To Be Deleted After Refactoring Part 2 is done
    let backgroundColor = UIColor.compositeColor(.background)
    let gridLayoutBackground = UIColor.compositeColor(.gridLayoutBackground)
    let onSurfaceColor = UIColor.compositeColor(.onSurface)
    let mute = UIColor.compositeColor(.mute)
    let disableColor = UIColor.compositeColor(.disabled)
    let error = UIColor.compositeColor(.error)
    let onBackground = UIColor.compositeColor(.onBackground)
    let onError = UIColor.compositeColor(.onError)
    let onPrimary = UIColor.compositeColor(.onPrimary)
    let onSuccess = UIColor.compositeColor(.onSuccess)
    let onSurface = UIColor.compositeColor(.onSurface)
    let onWarning = UIColor.compositeColor(.onWarning)
    let success = UIColor.compositeColor(.success)
    let warning = UIColor.compositeColor(.warning)
    let surface = UIColor.compositeColor(.surface)
    let surfaceDarkColor = UIColor.compositeColor(.surfaceDarkColor)
    let surfaceLightColor = UIColor.compositeColor(.surfaceLightColor)
    let drawerColor = UIColor.compositeColor(.drawerColor)
    let popoverColor = UIColor.compositeColor(.popoverColor)
    let gradientColor = UIColor.compositeColor(.gradientColor)
    let hangup = UIColor.compositeColor(.hangup)
    let overlay = UIColor.compositeColor(.overlay)
    let onHoldBackground = UIColor.compositeColor(.onHoldBackground)
    let textSecondary = UIColor.compositeColor(.textSecondary)
    let iconSecondary = UIColor.compositeColor(.iconSecondary)

    // MARK: - Fluent UI Refactoring Starts - Part 1
    // MARK: - Shared
    let genericLabel: UIColor = FluentUI.Colors.textPrimary
    let genericIcon: UIColor = FluentUI.Colors.textPrimary
    let genericIconDisabled: UIColor = FluentUI.Colors.iconDisabled

    // MARK: - Setup View Colours
    lazy var setupTitleText: UIColor = genericLabel
    lazy var videoBackground: UIColor = {
        return dynamicColor(light: FluentUI.Colors.surfaceQuaternary,
                            dark: FluentUI.Colors.surfaceTertiary)
    }()
    lazy var premissionIcon: UIColor = genericIcon
    lazy var permissionText: UIColor = genericLabel
    lazy var previewGradient = UIColor.black.withAlphaComponent(0.7)
    lazy var warningLabel: UIColor = {
        return dynamicColor(light: FluentUI.Colors.Palette.warningShade30.color,
                            dark: UIColor.black)
    }()
    lazy var warningBanner: UIColor = {
        return dynamicColor(light: FluentUI.Colors.Palette.warningTint40.color,
                            dark: FluentUI.Colors.warning)
    }()

    // MARK: - Calling View Colours - Coming up in Part 2

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

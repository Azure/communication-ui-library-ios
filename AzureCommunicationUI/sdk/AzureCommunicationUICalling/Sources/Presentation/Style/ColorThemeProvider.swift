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
    let textSecondaryColor = UIColor.compositeColor(.textSecondaryColor)

    init(themeOptions: ThemeOptions?) {
        self.colorSchemeOverride = themeOptions?.colorSchemeOverride ?? .unspecified

        self.primaryColor = themeOptions?.primaryColor ?? Colors.Palette.communicationBlue.color
        self.primaryColorTint10 = themeOptions?.primaryColorTint10 ?? Colors.Palette.communicationBlueTint10.color
        self.primaryColorTint20 = themeOptions?.primaryColorTint20 ?? Colors.Palette.communicationBlueTint20.color
        self.primaryColorTint30 = themeOptions?.primaryColorTint30 ?? Colors.Palette.communicationBlueTint30.color
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

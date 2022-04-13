//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class ColorThemeProvider: ColorProviding {
    let primaryColor: UIColor
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

    init(themeConfiguration: ThemeConfiguration?) {
        self.primaryColor = themeConfiguration?.primaryColor ?? UIColor.compositeColor(.primary)
    }

    func primaryColor(for window: UIWindow) -> UIColor? {
        return primaryColor
    }

    func primaryTint10Color(for window: UIWindow) -> UIColor? {
        return primaryColor
    }

    func primaryTint20Color(for window: UIWindow) -> UIColor? {
        return primaryColor
    }

    func primaryTint30Color(for window: UIWindow) -> UIColor? {
        return primaryColor
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

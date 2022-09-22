//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit
import SwiftUI

class ColorThemeProvider {
    let colorSchemeOverride: UIUserInterfaceStyle

    let primaryColor: UIColor
    let primaryColorTint10: UIColor
    let primaryColorTint20: UIColor
    let primaryColorTint30: UIColor

//    let backgroundColor = UIColor.compositeColor(.background)
//    let gridLayoutBackground = UIColor.compositeColor(.gridLayoutBackground)
//    let onSurfaceColor = UIColor.compositeColor(.onSurface)
//    let mute = UIColor.compositeColor(.mute)
//    let disableColor = UIColor.compositeColor(.disabled)
//    let error = UIColor.compositeColor(.error)
//    let onBackground = UIColor.compositeColor(.onBackground)
//    let onError = UIColor.compositeColor(.onError)
//    let onPrimary = UIColor.compositeColor(.onPrimary)
//    let onSuccess = UIColor.compositeColor(.onSuccess)
//    let onSurface = UIColor.compositeColor(.onSurface)
//    let onWarning = UIColor.compositeColor(.onWarning)
//    let success = UIColor.compositeColor(.success)
//    let warning = UIColor.compositeColor(.warning)
//    let surface = UIColor.compositeColor(.surface)
//    let surfaceDarkColor = UIColor.compositeColor(.surfaceDarkColor)
//    let surfaceLightColor = UIColor.compositeColor(.surfaceLightColor)
//    let drawerColor = UIColor.compositeColor(.drawerColor)
//    let popoverColor = UIColor.compositeColor(.popoverColor)
//    let gradientColor = UIColor.compositeColor(.gradientColor)
//    let hangup = UIColor.compositeColor(.hangup)
//    let overlay = UIColor.compositeColor(.overlay)
//    let onHoldBackground = UIColor.compositeColor(.onHoldBackground)

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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    static var grey50: Color {
        return Color(hex: "#F1F1F1")
    }
    static var grey150: Color {
        return Color(hex: "#3B3A39")
    }
    static var grey500: Color {
        return Color(hex: "#6E6E6E")
    }
    static var commBlueTint30: Color {
        return Color(hex: "#DEECF9")
    }
}

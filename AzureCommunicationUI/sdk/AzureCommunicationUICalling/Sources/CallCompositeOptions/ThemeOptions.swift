//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import FluentUI

/// A protocol to allow customizing the theme.
///
/// Join Call Button - Background - Highlighted - Light Mode - Tint10
/// Join Call Button - Background - Highlighted - Dark Mode - Tint20
/// Join Call Button - Border - Normal - Light/Dark Mode - Tint10
/// Join Call Button - Border - Highlighted - Light/Dark Mode - Tint30
///
public protocol ThemeOptions {
    /// Provide a getter to force color scheme to be light or dark.
    var colorSchemeOverride: UIUserInterfaceStyle { get }

    /// Provide a getter to return a custom primary color.
    var primaryColor: UIColor { get }

    /// Provide a getter to return a custom primary color tint10.
    var primaryColorTint10: UIColor { get }

    /// Provide a getter to return a custom primary color tint20.
    var primaryColorTint20: UIColor { get }

    /// Provide a getter to return a custom primary color tint30.
    var primaryColorTint30: UIColor { get }
}

public extension ThemeOptions {
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
}

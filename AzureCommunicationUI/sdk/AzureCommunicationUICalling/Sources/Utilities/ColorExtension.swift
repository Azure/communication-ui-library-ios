//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

enum CompositeColor: String {
    case primary = "ACSPrimaryColor"
    case background = "backgroundColor"
    case gridLayoutBackground = "gridLayoutBackgroundColor"
    case disabled = "disabledColor"
    case error = "errorColor"
    case onBackground = "onBackgroundColor"
    case onDisabled = "onDisabledColor"
    case onError = "onErrorColor"
    case onPrimary = "onPrimaryColor"
    case onSuccess = "onSuccessColor"
    case onSurface = "onSurfaceColor"
    case mute = "mute"
    case onWarning = "onWarningColor"
    case success = "successColor"
    case warning = "warningColor"
    case surface = "surfaceColor"
    case surfaceDarkColor = "surfaceDarkColor"
    case surfaceLightColor = "surfaceLightColor"
    case drawerColor = "drawerColor"
    case popoverColor = "popoverColor"
    case gradientColor = "gradientColor"
    case hangup = "hangupColor"
    case overlay = "overlayColor"
    case onHoldBackground = "onHoldBackground"
    case textSecondaryColor
}

extension UIColor {
    static func compositeColor(_ name: CompositeColor) -> UIColor {
        return getAssetsColor(named: name.rawValue)
    }

    private static func getAssetsColor(named: String) -> UIColor {
        if let assetsColor = UIColor(named: "Color/" + named,
                                     in: Bundle(for: CallComposite.self),
                                     compatibleWith: nil) {
            return assetsColor
        } else {
            preconditionFailure("invalid asset color")
        }
    }
}

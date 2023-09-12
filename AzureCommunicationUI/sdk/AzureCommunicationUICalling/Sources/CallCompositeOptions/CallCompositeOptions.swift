//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    private(set) var deviceToken: String = ""
    private(set) var themeOptions: ThemeOptions?
    private(set) var localizationOptions: LocalizationOptions?
    private(set) var setupScreenOrientation: OrientationOptions?
    private(set) var callingScreenOrientation: OrientationOptions?
    private(set) var enableMultitasking: Bool = false
    private(set) var enableSystemPiPWhenMultitasking: Bool = false

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter theme: ThemeOptions for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationOptions for specifying
    ///  localization customization. Default value is `nil`.
    /// - Parameter setupScreenOrientation: setupScreenOrientation for specifying
    ///  setupScreenOrientation customization. Default value is `nil`.
    /// - Parameter callingScreenOrientation: callingScreenOrientation for specifying
    ///  callingScreenOrientation customization. Default value is `nil`.
    /// - Parameter enableMultitasking: while on the call, user can go back to
    ///  previous View from the call composite.
    /// - Parameter enableSystemPiPWhenMultitasking: When enableMultitasking is set to true, enables a system
    ///  Picture-in-picture mode when user navigates away from call composite.
    public init(theme: ThemeOptions? = nil,
                deviceToken: String = "",
                localization: LocalizationOptions? = nil,
                setupScreenOrientation: OrientationOptions? = nil,
                callingScreenOrientation: OrientationOptions? = nil,
                enableMultitasking: Bool = false,
                enableSystemPiPWhenMultitasking: Bool = false) {
        self.themeOptions = theme
        self.deviceToken = deviceToken
        self.localizationOptions = localization
        self.setupScreenOrientation = setupScreenOrientation
        self.callingScreenOrientation = callingScreenOrientation
        self.enableMultitasking = enableMultitasking
        self.enableSystemPiPWhenMultitasking = enableSystemPiPWhenMultitasking
    }
}

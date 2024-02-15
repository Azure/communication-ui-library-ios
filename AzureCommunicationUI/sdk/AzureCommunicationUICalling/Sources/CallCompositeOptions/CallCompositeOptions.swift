//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    private(set) var themeOptions: ThemeOptions?
    private(set) var localizationOptions: LocalizationOptions?
    private(set) var enableMultitasking: Bool = false
    private(set) var enableSystemPipWhenMultitasking: Bool = false
    private(set) var setupScreenOrientation: OrientationOptions?
    private(set) var callingScreenOrientation: OrientationOptions?

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter theme: ThemeOptions for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationOptions for specifying
    ///  localization customization. Default value is `nil`.
    /// - Parameter setupScreenOrientation: setupScreenOrientation for specifying
    ///  setupScreenOrientation customization. Default value is `nil`.
    /// - Parameter callingScreenOrientation: callingScreenOrientation for specifying
    ///  callingScreenOrientation customization. Default value is `nil`.
    /// - Parameter enableMultitasking: enables user to navigate in the application
    ///  while on the call. Default value is `false`.
    /// - Parameter enableSystemPictureInPictureWhenMultitasking: enables syspem Picture-in-Picture while
    ///  enableMultitasking is on and user navigates away from call view. Default value is `false`.
    public init(theme: ThemeOptions? = nil,
                localization: LocalizationOptions? = nil,
                setupScreenOrientation: OrientationOptions? = nil,
                callingScreenOrientation: OrientationOptions? = nil,
                enableMultitasking: Bool = false,
                enableSystemPictureInPictureWhenMultitasking: Bool = false) {
        self.themeOptions = theme
        self.localizationOptions = localization
        self.setupScreenOrientation = setupScreenOrientation
        self.callingScreenOrientation = callingScreenOrientation
        self.enableMultitasking = enableMultitasking
        self.enableSystemPipWhenMultitasking = enableSystemPictureInPictureWhenMultitasking
    }
}

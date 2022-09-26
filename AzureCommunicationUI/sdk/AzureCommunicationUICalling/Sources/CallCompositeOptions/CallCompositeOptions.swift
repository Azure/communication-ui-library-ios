//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    let themeOptions: ThemeOptions?
    let localizationOptions: LocalizationOptions?
    let controlsOptions: ControlsOptions?
    let diagnosticsOptions: DiagnosticsOptions?

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter theme: ThemeOptions for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationOptions for specifying
    ///  localization customization. Default value is `nil`.
    public init(theme: ThemeOptions? = nil,
                localization: LocalizationOptions? = nil,
                controlsOptions: ControlsOptions? = nil,
                diagnosticsOptions: DiagnosticsOptions? = nil) {
        self.themeOptions = theme
        self.localizationOptions = localization
        self.controlsOptions = controlsOptions
        self.diagnosticsOptions = diagnosticsOptions
    }
}

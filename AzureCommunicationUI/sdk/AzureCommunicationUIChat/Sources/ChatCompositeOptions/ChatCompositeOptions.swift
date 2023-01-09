//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating ChatComposite.
struct ChatCompositeOptions {
    private(set) var themeOptions: ThemeOptions?
    private(set) var localizationOptions: LocalizationOptions?

    /// Creates an instance of ChatCompositeOptions with related options.
    /// - Parameter theme: ThemeOptions for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationOptions for specifying
    ///  localization customization. Default value is `nil`.
    init(theme: ThemeOptions? = nil,
         localization: LocalizationOptions? = nil) {
        self.themeOptions = theme
        self.localizationOptions = localization
    }
}

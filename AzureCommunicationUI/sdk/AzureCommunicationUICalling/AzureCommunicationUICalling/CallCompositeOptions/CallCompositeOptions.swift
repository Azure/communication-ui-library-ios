//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    private(set) var themeConfiguration: ThemeConfiguration?
    private(set) var localizationConfiguration: LocalizationConfiguration?

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter theme: ThemeConfiguration for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationConfiguration for specifying
    ///  localization customization. Default value is `nil`.
    public init(theme: ThemeConfiguration? = nil,
                localization: LocalizationConfiguration? = nil) {
        self.themeConfiguration = theme
        self.localizationConfiguration = localization
    }
}

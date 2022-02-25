//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    var themeConfiguration: ThemeConfiguration?
    var localizationConfiguration: LocalizationConfiguration?

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter themeConfiguration: ThemeConfiguration for changing color pattern
    /// - Parameter localizationConfiguration: LocalizationConfiguration for changing
    ///  locale, right-to-left mirroring layout, and customize locale strings
    public init(themeConfiguration: ThemeConfiguration? = nil,
                localizationConfiguration: LocalizationConfiguration? = nil) {
        self.themeConfiguration = themeConfiguration
        self.localizationConfiguration = localizationConfiguration
    }

    public init() { }
}

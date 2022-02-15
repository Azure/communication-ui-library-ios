//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    var themeConfiguration: ThemeConfiguration?

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter themeConfiguration: ThemeConfiguration for changing color pattern
    public init(themeConfiguration: ThemeConfiguration) {
        self.themeConfiguration = themeConfiguration
    }

    public init() { }
}

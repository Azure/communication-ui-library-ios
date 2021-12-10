//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public struct CallCompositeOptions {
    var themeConfiguration: ThemeConfiguration?

    public init(themeConfiguration: ThemeConfiguration) {
        self.themeConfiguration = themeConfiguration
    }

    public init() { }
}

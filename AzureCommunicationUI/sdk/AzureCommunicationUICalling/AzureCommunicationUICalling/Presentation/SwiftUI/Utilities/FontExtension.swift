//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import UIKit

extension UIFont {
    var font: Font {
        return Font(self as CTFont)
    }
}

extension Fonts {
    static var button2Accessibility: UIFont { return Fonts.button2.withSize(20) }
}

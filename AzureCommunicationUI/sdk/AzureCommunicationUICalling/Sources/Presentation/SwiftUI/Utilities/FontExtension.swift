//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import UIKit
import FluentUI

extension UIFont {
    var font: Font {
        return Font(self as CTFont)
    }
}

extension Fonts {
    static var button1Accessibility: UIFont { return Fonts.button1.withSize(26) }
    static var button2Accessibility: UIFont { return Fonts.button2.withSize(20) }
}

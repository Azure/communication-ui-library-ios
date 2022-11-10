//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI
import SwiftUI

enum CompositeIcon: String {
    case leftArrow = "ic_ios_arrow_left_24"
    case send = "ic_fluent_send_24_filled"
    case readReceipt = "ic_fluent_eye_12_regular"
}

struct IconProvider {
    func getUIImage(for iconName: CompositeIcon) -> UIImage? {
        UIImage(named: "Icon/\(iconName.rawValue)",
                in: Bundle(for: ChatComposite.self),
                compatibleWith: nil)
    }
    func getImage(for iconName: CompositeIcon) -> Image {
        Image("Icon/\(iconName.rawValue)", bundle: Bundle(for: ChatComposite.self))
            .resizable()
            .renderingMode(.template)
    }
}

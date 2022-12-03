//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI
import SwiftUI

enum CompositeIcon: String {
    case leftArrow = "ic_ios_arrow_left_24_filled"
    case downArrow = "ic_fluent_arrow_down_24_filled"
    case send = "ic_fluent_send_24_filled"
    case sendDisabled = "ic_fluent_send_24_regular"
    case readReceipt = "ic_fluent_eye_12_regular"
    case messageSending = "ic_fluent_circle_12_regular"
    case messageDelivered = "ic_fluent_checkmark_circle_12_regular"
    case messageSendFailed = "ic_fluent_error_circle_12_regular"
    case systemJoin = "ic_fluent_person_add_24_regular"
    case systemLeave = "ic_fluent_person_remove_24_regular"
}

struct IconProvider {
    func getUIImage(for iconName: CompositeIcon) -> UIImage? {
        UIImage(named: "Icon/\(iconName.rawValue)",
                in: Bundle(for: ChatAdapter.self),
                compatibleWith: nil)
    }
    func getImage(for iconName: CompositeIcon) -> Image {
        Image("Icon/\(iconName.rawValue)", bundle: Bundle(for: ChatAdapter.self))
            .resizable()
            .renderingMode(.template)
    }
}

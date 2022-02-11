//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class IconWithLabelButtonViewModel: ObservableObject {
    enum ButtonTypeColor {
        case colorThemedWhite
        case white
    }

    @Published var iconName: CompositeIcon
    @Published var buttonTypeColor: ButtonTypeColor
    @Published var buttonLabel: String
    @Published var accessibilityLabel: String?
    @Published var accessibilityValue: String?
    @Published var isDisabled: Bool
    var action: (() -> Void)

    init(iconName: CompositeIcon,
         buttonTypeColor: ButtonTypeColor,
         buttonLabel: String,
         isDisabled: Bool = false,
         action: @escaping (() -> Void) = {}) {
        self.iconName = iconName
        self.buttonTypeColor = buttonTypeColor
        self.buttonLabel = buttonLabel
        self.isDisabled = isDisabled
        self.action = action
    }

    func update(iconName: CompositeIcon, buttonLabel: String) {
        if self.iconName != iconName {
            self.iconName = iconName
        }
        if self.buttonLabel != buttonLabel {
            self.buttonLabel = buttonLabel
        }
    }

    func update(accessibilityLabel: String) {
        if self.accessibilityLabel != accessibilityLabel {
            self.accessibilityLabel = accessibilityLabel
        }
    }

    func update(accessibilityValue: String) {
        if self.accessibilityValue != accessibilityValue {
            self.accessibilityValue = accessibilityValue
        }
    }

    func update(isDisabled: Bool) {
        if self.isDisabled != isDisabled {
            self.isDisabled = isDisabled
        }
    }

    func update(buttonTypeColor: ButtonTypeColor) {
        if self.buttonTypeColor != buttonTypeColor {
            self.buttonTypeColor = buttonTypeColor
        }
    }
}

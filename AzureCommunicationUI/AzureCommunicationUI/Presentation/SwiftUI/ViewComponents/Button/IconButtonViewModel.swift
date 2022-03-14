//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class IconButtonViewModel: ObservableObject {
    enum ButtonType {
        case controlButton
        case roundedRectButton
        case infoButton
        case dismissButton
        case cameraSwitchButtonPip
        case cameraSwitchButtonFull
    }

    @Published var iconName: CompositeIcon
    @Published var accessibilityLabel: String?
    @Published var accessibilityValue: String?
    @Published var accessibilityHint: String?
    @Published var isDisabled: Bool
    let buttonType: ButtonType
    var action: (() -> Void)

    init(iconName: CompositeIcon,
         buttonType: ButtonType = .controlButton,
         isDisabled: Bool = false,
         action: @escaping (() -> Void) = {}) {
        self.iconName = iconName
        self.buttonType = buttonType
        self.isDisabled = isDisabled
        self.action = action
    }

    func update(iconName: CompositeIcon?) {
        if iconName != nil && self.iconName != iconName {
            self.iconName = iconName!
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

    func update(accessibilityHint: String) {
        if self.accessibilityHint != accessibilityHint {
            self.accessibilityHint = accessibilityHint
        }
    }

    func update(isDisabled: Bool) {
        if self.isDisabled != isDisabled {
            self.isDisabled = isDisabled
        }
    }
}

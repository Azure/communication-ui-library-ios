//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import SwiftUI

class IconButtonViewModel: ObservableObject {
    enum ButtonType {
        case controlButton
        case roundedRectButton
        case infoButton
        case dismissButton
        case cameraSwitchButtonPip
        case cameraSwitchButtonFull
    }

    @Published var iconName: CompositeIcon?
    @Published var icon: UIImage?
    @Published var accessibilityLabel: String?
    @Published var accessibilityValue: String?
    @Published var accessibilityHint: String?
    @Published var isDisabled: Bool
    @Published var isVisible: Bool

    var buttonType: ButtonType
    var action: (() -> Void)

    init(iconName: CompositeIcon?,
         buttonType: ButtonType = .controlButton,
         isDisabled: Bool = false,
         isVisible: Bool = true,
         action: @escaping (() -> Void) = {}) {
        self.iconName = iconName
        self.buttonType = buttonType
        self.isDisabled = isDisabled
        self.action = action
        self.isVisible = isVisible
    }

    convenience init(icon: UIImage,
                     buttonType: ButtonType = .controlButton,
                     isDisabled: Bool = false,
                     isVisible: Bool = true,
                     action: @escaping (() -> Void) = {}) {
        self.init(iconName: nil,
                  buttonType: buttonType,
                  isDisabled: isDisabled,
                  isVisible: isVisible,
                  action: action)
        self.icon = icon
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

    func update(isVisible: Bool) {
        if self.isVisible != isVisible {
            self.isVisible = isVisible
        }
    }
}

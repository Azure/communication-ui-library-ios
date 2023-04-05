//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class IconWithLabelButtonViewModel<T: ButtonState>: ObservableObject {
    enum ButtonTypeColor {
        case colorThemedWhite
        case white
    }
    @Published var selectedButtonState: T
    @Published var localizationProvider: LocalizationProviderProtocol
    @Published var iconName: CompositeIcon
    @Published var buttonTypeColor: ButtonTypeColor
    @Published var buttonLabel: String?
    @Published var accessibilityLabel: String?
    @Published var accessibilityValue: String?
    @Published var accessibilityHint: String?
    @Published var isDisabled: Bool
    var action: (() -> Void)

    init(selectedButtonState: T,
         localizationProvider: LocalizationProviderProtocol,
         buttonTypeColor: ButtonTypeColor,
         isDisabled: Bool = false,
         action: @escaping (() -> Void) = {}) {
        self.selectedButtonState = selectedButtonState
        self.localizationProvider = localizationProvider
        self.iconName = selectedButtonState.iconName
        self.buttonTypeColor = buttonTypeColor
        self.buttonLabel = localizationProvider.getLocalizedString(selectedButtonState.localizationKey)
        self.isDisabled = isDisabled
        self.action = action
    }

    func update(selectedButtonState: T) {
        if self.selectedButtonState.localizationKey != selectedButtonState.localizationKey {
            self.selectedButtonState = selectedButtonState
            self.buttonLabel = localizationProvider.getLocalizedString(selectedButtonState.localizationKey)
            self.iconName = selectedButtonState.iconName
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

    func update(buttonTypeColor: ButtonTypeColor) {
        if self.buttonTypeColor != buttonTypeColor {
            self.buttonTypeColor = buttonTypeColor
        }
    }
}

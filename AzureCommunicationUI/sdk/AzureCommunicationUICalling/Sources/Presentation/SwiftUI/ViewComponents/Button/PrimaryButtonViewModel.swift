//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import Combine

class PrimaryButtonViewModel: ObservableObject {
    @Published var isDisabled: Bool
    @Published var accessibilityLabel: String?
    let buttonStyle: FluentUI.ButtonStyle
    let buttonLabel: String
    let iconName: CompositeIcon?
    let paddings: CompositeButton.Paddings?
    let themeOptions: ThemeOptions
    var action: (() -> Void)

    init(buttonStyle: FluentUI.ButtonStyle,
         buttonLabel: String,
         iconName: CompositeIcon? = nil,
         isDisabled: Bool = false,
         paddings: CompositeButton.Paddings? = nil,
         themeOptions: ThemeOptions,
         action: @escaping (() -> Void) = {}) {
        self.buttonStyle = buttonStyle
        self.buttonLabel = buttonLabel
        self.iconName = iconName
        self.isDisabled = isDisabled
        self.action = action
        self.paddings = paddings
        self.themeOptions = themeOptions
    }

    func update(isDisabled: Bool) {
        if self.isDisabled != isDisabled {
            self.isDisabled = isDisabled
        }
    }

    func update(accessibilityLabel: String?) {
        if self.accessibilityLabel != accessibilityLabel {
            self.accessibilityLabel = accessibilityLabel
        }
    }
}

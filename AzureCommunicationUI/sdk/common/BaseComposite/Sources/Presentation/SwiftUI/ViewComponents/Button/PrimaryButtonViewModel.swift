//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import Combine

class PrimaryButtonViewModel: ObservableObject {
    let buttonStyle: FluentUI.ButtonStyle
    let iconName: CompositeIcon?
    
    var action: (() -> Void)

    @Published var buttonLabel: String
    @Published var isDisabled: Bool
    @Published var accessibilityLabel: String?

    init(buttonStyle: FluentUI.ButtonStyle,
         buttonLabel: String,
         iconName: CompositeIcon? = nil,
         isDisabled: Bool = false,
         action: @escaping (() -> Void) = {}) {
        self.buttonStyle = buttonStyle
        self.buttonLabel = buttonLabel
        self.iconName = iconName
        self.isDisabled = isDisabled
        self.action = action
    }

    func update(buttonLabel: String?) {
        if buttonLabel != nil && self.buttonLabel != buttonLabel {
            self.buttonLabel = buttonLabel!
        }
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

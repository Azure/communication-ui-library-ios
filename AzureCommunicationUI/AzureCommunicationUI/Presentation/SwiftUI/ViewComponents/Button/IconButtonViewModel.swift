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

    func update(iconName: CompositeIcon) {
        if self.iconName != iconName {
            self.iconName = iconName
        }
    }

    func update(isDisabled: Bool) {
        if self.isDisabled != isDisabled {
            self.isDisabled = isDisabled
        }
    }
}

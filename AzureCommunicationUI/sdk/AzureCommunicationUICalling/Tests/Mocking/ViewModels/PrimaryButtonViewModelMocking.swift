//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
@testable import AzureCommunicationUICalling

class PrimaryButtonViewModelMocking: PrimaryButtonViewModel {
    private let updateState: ((Bool) -> Void)?

    init(buttonStyle: FluentUI.ButtonStyle,
         buttonLabel: String,
         iconName: CompositeIcon? = nil,
         isDisabled: Bool = false,
         action: @escaping (() -> Void) = {},
         updateState: ((Bool) -> Void)? = nil) {
        self.updateState = updateState
        super.init(buttonStyle: buttonStyle,
                   buttonLabel: buttonLabel,
                   iconName: iconName,
                   isDisabled: isDisabled,
                   action: action)
    }

    override func update(isDisabled: Bool) {
        updateState?(isDisabled)
    }
}

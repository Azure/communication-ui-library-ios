//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class IconWithLabelButtonViewModelMocking<T: ButtonState>: IconWithLabelButtonViewModel<T> {
    var updateButtonInfo: ((CompositeIcon?, String?) -> Void)?
    var updateDisabledState: ((Bool) -> Void)?

    func update(iconName: CompositeIcon?, buttonLabel: String?) {
        updateButtonInfo?(iconName, buttonLabel)
    }

    override func update(isDisabled: Bool) {
        updateDisabledState?(isDisabled)
    }
}

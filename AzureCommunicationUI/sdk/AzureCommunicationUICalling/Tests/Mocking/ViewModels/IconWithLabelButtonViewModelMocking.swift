//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class IconWithLabelButtonViewModelMocking<T: ButtonState>: IconWithLabelButtonViewModel<T> {
    var updateButtonInfo: ((T) -> Void)?
    var updateDisabledState: ((Bool) -> Void)?

    override func update(selectedButtonState: T) {
        updateButtonInfo?(selectedButtonState)
    }

    override func update(isDisabled: Bool) {
        updateDisabledState?(isDisabled)
    }
}

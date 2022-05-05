//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class IconWithLabelButtonViewModelMocking: IconWithLabelButtonViewModel {
    var updateButtonInfo: ((CompositeIcon?, String?) -> Void)?
    var updateDisabledState: ((Bool) -> Void)?

    override func update(iconName: CompositeIcon?, buttonLabel: String?) {
        updateButtonInfo?(iconName, buttonLabel)
    }

    override func update(isDisabled: Bool) {
        updateDisabledState?(isDisabled)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class IconButtonViewModelMocking: IconButtonViewModel {
    var updateIcon: ((CompositeIcon?) -> Void)?
    var updateIsDisabledState: ((Bool) -> Void)?

    override func update(iconName: CompositeIcon?) {
        updateIcon?(iconName)
    }

    override func update(isDisabled: Bool) {
        updateIsDisabledState?(isDisabled)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LeaveCallConfirmationViewModel {
    let icon: CompositeIcon
    let title: String
    let action: (() -> Void)

    init(icon: CompositeIcon,
         title: String,
         action: @escaping (() -> Void)) {
        self.icon = icon
        self.title = title
        self.action = action
    }
}

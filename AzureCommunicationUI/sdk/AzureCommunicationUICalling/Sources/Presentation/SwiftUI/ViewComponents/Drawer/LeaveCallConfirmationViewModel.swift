//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LeaveCallConfirmationViewModel {
    let icon: CompositeIcon
    let title: String
    let accessibilityIdentifier: String
    let action: (() -> Void)

    init(icon: CompositeIcon,
         title: String,
         accessibilityIdentifier: String,
         action: @escaping (() -> Void)) {
        self.icon = icon
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
}

extension LeaveCallConfirmationViewModel: Equatable {
    static func == (lhs: LeaveCallConfirmationViewModel,
                    rhs: LeaveCallConfirmationViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.icon == rhs.icon
    }
}

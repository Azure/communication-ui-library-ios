//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class DrawerListItemViewModel {
    let icon: CompositeIcon
    let title: String
    let accessibilityIdentifier: String
    let action: (() -> Void)

    init(icon: CompositeIcon,
         title: String,
         accessibilityIdentifier: String,
         action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
}

extension DrawerListItemViewModel: Equatable {
    static func == (lhs: DrawerListItemViewModel,
                    rhs: DrawerListItemViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.icon == rhs.icon
    }
}

class SelectableDrawerListItemViewModel: DrawerListItemViewModel {
    let isSelected: Bool

    init(icon: CompositeIcon,
         title: String,
         accessibilityIdentifier: String,
         isSelected: Bool,
         action: @escaping () -> Void) {
        self.isSelected = isSelected
        super.init(icon: icon, title: title, accessibilityIdentifier: accessibilityIdentifier, action: action)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class DrawerListItemViewModel {
    let compositIcon: CompositeIcon?
    var icon: UIImage?
    let title: String
    let accessibilityIdentifier: String
    var action: (() -> Void)
    var isEnabled: Bool

    init(compositeIcon: CompositeIcon?,
         title: String,
         accessibilityIdentifier: String,
         action: @escaping () -> Void,
         isEnabled: Bool = true) {
        self.compositIcon = compositeIcon
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.isEnabled = isEnabled
    }

    convenience init(compositeIcon: CompositeIcon,
                     title: String,
                     accessibilityIdentifier: String) {
        self.init(compositeIcon: compositeIcon,
                  title: title,
                  accessibilityIdentifier: accessibilityIdentifier,
                  action: {},
                  isEnabled: true)
    }

    convenience init(icon: UIImage,
                     title: String,
                     action: @escaping () -> Void,
                     isEnabled: Bool = true) {

        self.init(compositeIcon: nil,
                  title: title,
                  accessibilityIdentifier: "",
                  action: action,
                  isEnabled: isEnabled)

        self.icon = icon
    }
}

extension DrawerListItemViewModel: Equatable {
    static func == (lhs: DrawerListItemViewModel,
                    rhs: DrawerListItemViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.compositIcon == rhs.compositIcon &&
        lhs.icon == rhs.icon
    }
}

class SelectableDrawerListItemViewModel: DrawerListItemViewModel {
    let isSelected: Bool

    init(compositeIcon: CompositeIcon,
         title: String,
         accessibilityIdentifier: String,
         isSelected: Bool,
         action: @escaping () -> Void) {
        self.isSelected = isSelected
        super.init(compositeIcon: compositeIcon,
                   title: title,
                   accessibilityIdentifier: accessibilityIdentifier,
                   action: action)
    }
}

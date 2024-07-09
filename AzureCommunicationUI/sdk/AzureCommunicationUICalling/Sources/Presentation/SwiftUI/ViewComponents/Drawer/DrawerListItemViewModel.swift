//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// This class contains all the View Models for List based Drawers (Participants, Audio Devices, Leave Call Confirm)
// Each ViewModel represents a line-item supported on one of these lits
class BaseDrawerItemViewModel: Identifiable {
    let title: String

    init (title: String) {
        self.title = title
    }
}

extension BaseDrawerItemViewModel: Equatable {
    static func == (lhs: BaseDrawerItemViewModel,
                    rhs: BaseDrawerItemViewModel) -> Bool {
        return lhs.title == rhs.title
    }
}

class DrawerListItemViewModel: BaseDrawerItemViewModel {

    let startIcon: CompositeIcon?
    let accessibilityIdentifier: String
    var action: (() -> Void)?
    var isEnabled: Bool

    init(title: String,
         accessibilityIdentifier: String,
         action: (() -> Void)? = nil,
         startIcon: CompositeIcon? = nil,
         endIcon: CompositeIcon? = nil,
         isEnabled: Bool = true) {
        self.startIcon = startIcon
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.isEnabled = isEnabled
        super.init(title: title)
    }

    convenience init(title: String,
                     icon: CompositeIcon,
                     accessibilityIdentifier: String) {
        self.init(title: title,
                  accessibilityIdentifier: accessibilityIdentifier,
                  action: nil,
                  startIcon: icon,
                  endIcon: nil,
                  isEnabled: true)
    }
}

extension DrawerListItemViewModel {
    static func == (lhs: DrawerListItemViewModel,
                    rhs: DrawerListItemViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.startIcon == rhs.startIcon &&
        lhs.isEnabled == rhs.isEnabled
    }
}

class SelectableDrawerListItemViewModel: BaseDrawerItemViewModel {
    let isSelected: Bool
    let accessibilityIdentifier: String
    let icon: CompositeIcon
    let action: () -> Void

    init(icon: CompositeIcon,
         title: String,
         accessibilityIdentifier: String,
         isSelected: Bool,
         action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier
        self.icon = icon
        super.init(title: title)
    }
}

class TitleDrawerListItemViewModel: BaseDrawerItemViewModel {
    let accessibilityIdentifier: String

    init(title: String, accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
        super.init(title: title)
    }
}

class BodyTextDrawerListItemViewModel: BaseDrawerItemViewModel {
    let accessibilityIdentifier: String

    init(title: String, accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
        super.init(title: title)
    }
}

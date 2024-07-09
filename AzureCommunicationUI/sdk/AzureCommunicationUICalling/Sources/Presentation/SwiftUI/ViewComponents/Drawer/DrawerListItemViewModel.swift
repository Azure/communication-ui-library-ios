//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// This class contains all the View Models for List based Drawers (Participants, Audio Devices, Leave Call Confirm)
// Each ViewModel represents a line-item supported on one of these lits
protocol BaseDrawerItemViewModel {}

struct DrawerListItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let startIcon: CompositeIcon?
    let accessibilityIdentifier: String
    let action: (() -> Void)?
    let isEnabled: Bool

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
        self.title = title
    }
}

struct SelectableDrawerListItemViewModel: BaseDrawerItemViewModel {
    let title: String
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
        self.title = title
    }
}

struct TitleDrawerListItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let accessibilityIdentifier: String
}

struct BodyTextDrawerListItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let accessibilityIdentifier: String
}

struct BodyTextWithActionDrawerListItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let accessibilityIdentifier: String
    let action: () -> Void
    let actionText: String
}

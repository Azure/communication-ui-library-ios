//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

// This class contains all the View Models for List based Drawers (Participants, Audio Devices, Leave Call Confirm)
// Each ViewModel represents a line-item supported on one of these lits
protocol BaseDrawerItemViewModel {}

struct DrawerGenericItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let subtitle: String?
    let startIcon: CompositeIcon?
    let endIcon: CompositeIcon?
    let accessibilityIdentifier: String
    let action: (() -> Void)?
    let isEnabled: Bool
    let isToggleOn: Binding<Bool>?
    let showsToggle: Bool

    init(title: String,
         subtitle: String? = "",
         accessibilityIdentifier: String,
         action: (() -> Void)? = nil,
         startIcon: CompositeIcon? = nil,
         endIcon: CompositeIcon? = nil,
         showToggle: Bool = false,
         isToggleOn: Binding<Bool>? = nil,
         isEnabled: Bool = true) {
        self.startIcon = startIcon
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.isEnabled = isEnabled
        self.title = title
        self.isToggleOn = isToggleOn
        self.showsToggle = showToggle
        self.subtitle = subtitle
        self.endIcon = endIcon
    }
}

struct DrawerSelectableItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let isSelected: Bool
    let accessibilityIdentifier: String
    let icon: CompositeIcon?
    let action: () -> Void

    init(icon: CompositeIcon?,
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
    let actionText: String
    let confirmTitle: String
    let confirmAccept: String
    let confirmDeny: String
    let accept: (() -> Void)
    let deny: (() -> Void)
}
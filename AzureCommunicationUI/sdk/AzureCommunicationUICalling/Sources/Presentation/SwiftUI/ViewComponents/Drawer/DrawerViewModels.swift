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
    let startCompositeIcon: CompositeIcon?
    let startIcon: UIImage?
    let endIcon: CompositeIcon?
    let accessibilityIdentifier: String
    let action: (() -> Void)?
    let isEnabled: Bool
    let isToggleOn: Binding<Bool>?
    let showsToggle: Bool
    let accessibilityTraits: AccessibilityTraits?

    init(title: String,
         subtitle: String? = "",
         accessibilityIdentifier: String,
         accessibilityTraits: AccessibilityTraits? = nil,
         action: (() -> Void)? = nil,
         startCompositeIcon: CompositeIcon? = nil,
         startIcon: UIImage? = nil,
         endIcon: CompositeIcon? = nil,
         showToggle: Bool = false,
         isToggleOn: Binding<Bool>? = nil,
         isEnabled: Bool = true) {
        self.startCompositeIcon = startCompositeIcon
        self.startIcon = startIcon
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.isEnabled = isEnabled
        self.title = title
        self.isToggleOn = isToggleOn
        self.showsToggle = showToggle
        self.subtitle = subtitle
        self.endIcon = endIcon
        self.accessibilityTraits = accessibilityTraits
    }
}

struct DrawerSelectableItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let isSelected: Bool
    let accessibilityIdentifier: String
    let accessibilityLabel: String?
    let icon: CompositeIcon?
    let action: () -> Void

    init(icon: CompositeIcon?,
         title: String,
         accessibilityIdentifier: String,
         accessibilityLabel: String,
         isSelected: Bool,
         action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
        self.icon = icon
        self.title = title
    }
}

struct TitleDrawerListItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let startCompositeIcon: CompositeIcon?
    let startCompositeIconAction: (() -> Void)?
    let endIcon: CompositeIcon?
    let endIconAction: (() -> Void)?
    let expandIcon: CompositeIcon?
    let expandIconAction: (() -> Void)?
    let accessibilityIdentifier: String
    init(title: String,
         startCompositeIcon: CompositeIcon? = nil,
         startCompositeIconAction: (() -> Void)? = nil,
         endIcon: CompositeIcon? = nil,
         endIconAction: (() -> Void)? = nil,
         expandIcon: CompositeIcon? = nil,
         expandIconAction: (() -> Void)? = nil,
         accessibilityIdentifier: String) {
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.startCompositeIcon = startCompositeIcon
        self.startCompositeIconAction = startCompositeIconAction
        self.endIcon = endIcon
        self.endIconAction = endIconAction
        self.expandIcon = expandIcon
        self.expandIconAction = expandIconAction
    }
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

struct IconTextActionListItemViewModel: BaseDrawerItemViewModel {
    let title: String
    let isEnabled: Bool
    let startCompositeIcon: CompositeIcon
    let accessibilityIdentifier: String
    let confirmTitle: String
    let confirmMessage: String
    let confirmAccept: String
    let confirmDeny: String
    let accept: (() -> Void)
    let deny: (() -> Void)
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class DrawerListItemViewModel: Identifiable {
    let title: String
    let startIcon: CompositeIcon?
    let endIcon: CompositeIcon?
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
        self.endIcon = endIcon
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.isEnabled = isEnabled
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

extension DrawerListItemViewModel: Equatable {
    static func == (lhs: DrawerListItemViewModel,
                    rhs: DrawerListItemViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.startIcon == rhs.startIcon &&
        lhs.endIcon == rhs.endIcon &&
        lhs.isEnabled == rhs.isEnabled
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
        super.init(title: title, accessibilityIdentifier: accessibilityIdentifier, action: action, startIcon: icon)
    }
}

class TitleDrawerListItemViewModel: DrawerListItemViewModel {
    init(title: String, accessibilityIdentifier: String) {
        super.init(title: title,
                   accessibilityIdentifier: accessibilityIdentifier,
                   action: nil,
                   startIcon: nil)
    }
}

class BodyTextDrawerListItemViewModel: DrawerListItemViewModel {
    init(title: String, accessibilityIdentifier: String) {
        super.init(title: title,
                   accessibilityIdentifier: accessibilityIdentifier,
                   action: nil,
                   startIcon: nil)
    }
}

class ParticipantDrawerListItemViewModel: DrawerListItemViewModel {
    let isLocal: Bool

    init(displayName: String, isLocal: Bool, isMuted: Bool, action: (() -> Void)?) {
        self.isLocal = isLocal
        super.init(title: displayName,
                   accessibilityIdentifier: displayName,
                   action: action,
                   startIcon: nil,
                   endIcon: nil)
    }
}

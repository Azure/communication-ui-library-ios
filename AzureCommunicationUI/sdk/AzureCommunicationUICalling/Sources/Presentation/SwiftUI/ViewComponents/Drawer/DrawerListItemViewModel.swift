//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class DrawerListItemViewModel: Identifiable {
    let icon: CompositeIcon
    let title: String
    let subtitle: String?
    let accessibilityIdentifier: String
    let titleTrailingAccessoryView: CompositeIcon?
    var action: (() -> Void)
    let isToggleOn: Binding<Bool>?
    let showsToggle: Bool
    var isEnabled: Bool

    init(icon: CompositeIcon,
         title: String,
         subtitle: String? = "",
         accessibilityIdentifier: String,
         titleTrailingAccessoryView: CompositeIcon? = CompositeIcon.none,
         isToggleOn: Binding<Bool>? = nil,
         showToggle: Bool = false,
         isEnabled: Bool? = true,
         action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.subtitle = subtitle ?? ""
        self.isToggleOn = isToggleOn
        self.showsToggle = showToggle
        self.isEnabled = isEnabled ?? true
        self.titleTrailingAccessoryView = titleTrailingAccessoryView ?? Optional.none
    }
}

extension DrawerListItemViewModel: Equatable {
    static func == (lhs: DrawerListItemViewModel,
                    rhs: DrawerListItemViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.icon == rhs.icon && lhs.isEnabled == rhs.isEnabled
    }
}

class SelectableDrawerListItemViewModel: DrawerListItemViewModel {
    var isSelected: Bool

    init(icon: CompositeIcon,
         title: String,
         accessibilityIdentifier: String,
         isSelected: Bool,
         action: @escaping () -> Void) {
        self.isSelected = isSelected
        super.init(icon: icon, title: title, accessibilityIdentifier: accessibilityIdentifier, action: action)
    }
}

class TitleDrawerListItemViewModel: DrawerListItemViewModel {
    init(title: String, accessibilityIdentifier: String) {
        super.init(icon: .addParticipant,
                   title: title,
                   accessibilityIdentifier: accessibilityIdentifier, action: {})
    }
}

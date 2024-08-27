//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

internal struct DrawerGenericItemView: View {
    let item: DrawerGenericItemViewModel

    var body: some View {
        HStack {
            if let icon = item.startCompositeIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .foregroundColor(item.isEnabled ? .primary : .gray)
                    .accessibilityHidden(true)
            } else if let icon = item.startIcon {
                Image(uiImage: icon)
                    .frame(width: DrawerListConstants.iconSize,
                           height: DrawerListConstants.iconSize)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading) {
                Text(item.title)
                    .foregroundColor(item.isEnabled ? .primary : .gray)
                    .padding(.leading, DrawerListConstants.textPaddingLeading)
                    .font(.body)
                if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.leading, DrawerListConstants.textPaddingLeading)
                }
            }
            Spacer()
            if item.showsToggle, let isToggleOn = item.isToggleOn {
                Toggle("", isOn: isToggleOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .accessibilityLabel(Text(item.title))
            } else if let accessoryView = item.endIcon,
                      accessoryView != .none {
                Icon(name: item.endIcon ?? .rightChevron, size: DrawerListConstants.trailingIconSize)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .opacity(item.isEnabled ? 1.0 : DrawerListConstants.disabledOpacity)
        .onTapGesture {
            if item.isEnabled {
                if let action = item.action {
                    action()
                }
            }
        }
        .disabled(!item.isEnabled)
        .foregroundColor(item.isEnabled ? .primary : .gray)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .accessibilityAddTraits(item.accessibilityTraits ?? .isStaticText)
    }
}

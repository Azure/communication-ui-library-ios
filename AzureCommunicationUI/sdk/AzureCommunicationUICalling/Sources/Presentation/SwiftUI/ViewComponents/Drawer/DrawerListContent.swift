//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

// Helper to inflate DrawerListItemViewModel into a drawer
//
// Give it a list of DrawerListItemViewModels
// These come in 3 forms: Title, Selectable, Default (button)
// This will inflate the list to a SwiftUI view, to show in a drawer
// I.e. List[VM] -> Swift UI List View, for use with a drawer
//
//
internal struct DrawerListContent: View {
    let items: [DrawerListItemViewModel]
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ScrollView {
            VStack {
                ForEach(items) { option in
                    if let selectableItem = option as? SelectableDrawerListItemViewModel {
                        SelectableDrawerItemView(item: selectableItem)
                    } else if let titleItem = option as? TitleDrawerListItemViewModel {
                        DrawerTitleView(item: titleItem)
                    } else {
                        DrawerItemView(item: option)
                    }
                }
            }.padding([.bottom, .top], DrawerListConstants.listVerticalPadding)
        }
        .frame(maxHeight: maxHeight())
        .fixedSize(horizontal: false, vertical: true)
    }

    private func maxHeight() -> CGFloat {
        verticalSizeClass == .compact ? UIScreen.main.bounds.height / 2 : DrawerListConstants.maxHeight
    }
}

internal struct SelectableDrawerItemView: View {
    let item: SelectableDrawerListItemViewModel

    var body: some View {
        HStack {
            if item.icon != .none {
                Icon(name: item.icon, size: DrawerListConstants.iconSize)
                    .foregroundColor(.primary)
            }
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            Spacer()
            if item.isSelected {
                Icon(name: .checkmark, size: DrawerListConstants.iconSize)
            }
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            item.action()
        }
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }
}

internal struct DrawerItemView: View {
    let item: DrawerListItemViewModel

    var body: some View {
        HStack {
            Icon(name: item.icon, size: DrawerListConstants.iconSize)
                .foregroundColor(item.isEnabled ? .primary : .gray)
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
            } else if let accessoryView = item.titleTrailingAccessoryView,
                      accessoryView != .none {
                Icon(name: item.titleTrailingAccessoryView ?? .rightChevron, size: DrawerListConstants.trailingIconSize)
            }
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            item.action()
        }
        .disabled(!item.isEnabled)
        .foregroundColor(item.isEnabled ? .primary : .gray)
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }
}

internal struct DrawerTitleView: View {
    let item: TitleDrawerListItemViewModel

    var body: some View {
        HStack {
            Spacer()
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }
}

internal class DrawerListConstants {
    static let iconSize: CGFloat = 24
    static let trailingIconSize: CGFloat = 20
    static let textPaddingLeading: CGFloat = 8
    static let optionPaddingVertical: CGFloat = 12
    static let optionPaddingHorizontal: CGFloat = 16
    static let listVerticalPadding: CGFloat = 12
    static let maxHeight: CGFloat = 400
}

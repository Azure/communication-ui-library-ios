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
internal struct DrawerListView: View {
    let items: [BaseDrawerItemViewModel]

    // We don't always need this, but we do for Participants or whenever we show an Avatar
    // Provides just in case
    let avatarManager: AvatarViewManagerProtocol

    @State
    private var scrollViewContentSize: CGSize = .zero

    var body: some View {
        ScrollView {
            VStack {
                ForEach(items) { option in
                    if let selectableItem = option as? SelectableDrawerListItemViewModel {
                        SelectableDrawerItemView(item: selectableItem)
                    } else if let titleItem = option as? TitleDrawerListItemViewModel {
                        DrawerTitleView(item: titleItem)
                    } else if let bodyItem = option as? BodyTextDrawerListItemViewModel {
                        DrawerBodyTextView(item: bodyItem)
                    } else if let participantItem = option as? ParticipantsListCellViewModel {
                        DrawerParticipantView(item: participantItem, avatarManager: avatarManager)
                    } else if let drawerItem = option as? DrawerListItemViewModel {
                        DrawerItemView(item: drawerItem)
                    }
                }
            }
            .padding([.bottom, .top], DrawerListConstants.listVerticalPadding)
            .background(
                GeometryReader { geometry in
                    DispatchQueue.main.async {
                        scrollViewContentSize = geometry.size
                    }
                    return Color.clear
                }
            )
        }
        .frame(maxHeight: min(scrollViewContentSize.height, 400))
    }
}

internal struct SelectableDrawerItemView: View {
    let item: SelectableDrawerListItemViewModel

    var body: some View {
        HStack {
            let startIcon = item.icon
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
            if let icon = item.startIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .foregroundColor(.primary)
            }
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if let action = item.action {
                action()
            }
        }
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

internal struct DrawerBodyTextView: View {
    let item: BodyTextDrawerListItemViewModel

    var body: some View {
        HStack {
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }
}
internal struct DrawerParticipantView: View {
    let item: ParticipantsListCellViewModel
    let avatarManager: AvatarViewManagerProtocol

    var body: some View {
        let participantViewData = item.getParticipantViewData(from: avatarManager)
        let displayName = item.getCellDisplayName(with: participantViewData)
        HStack {
            // Placeholder replaced with actual avatar view
            CompositeAvatar(
                displayName: Binding.constant(displayName),
                avatarImage: Binding.constant(
                    item.isLocalParticipant ?
                    avatarManager.localParticipantViewData?.avatarImage :
                        avatarManager.avatarStorage.value(forKey: item.participantId ?? "")?.avatarImage
                ),
                isSpeaking: false,
                avatarSize: .size40
            )
            Text(displayName)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            Spacer()
            Icon(name: item.isMuted ? .micOff : .micOn, size: DrawerListConstants.iconSize)
        }
        .onTapGesture {
            // TADO: Do I need an on-tap to bridge? I think I do
//            guard let action = item.action else {
//                return
//            }
//            action()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier(item.getCellAccessibilityLabel(with: participantViewData))
    }
}

internal class DrawerListConstants {
    static let iconSize: CGFloat = 24
    static let textPaddingLeading: CGFloat = 8
    static let optionPaddingVertical: CGFloat = 12
    static let optionPaddingHorizontal: CGFloat = 16
    static let listVerticalPadding: CGFloat = 12
}

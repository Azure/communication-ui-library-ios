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
    let items: [DrawerListItemViewModel]

    // We don't always need this, but we do for Participants or whenever we show an Avatar
    // Provides just in case
    let avatarManager: AvatarViewManagerProtocol

    var body: some View {
        VStack {
            ForEach(items) { option in
                if let selectableItem = option as? SelectableDrawerListItemViewModel {
                    SelectableDrawerItemView(item: selectableItem)
                } else if let titleItem = option as? TitleDrawerListItemViewModel {
                    DrawerTitleView(item: titleItem)
                } else if let bodyItem = option as? BodyTextDrawerListItemViewModel {
                    DrawerBodyTextView(item: bodyItem)
                } else if let participantItem = option as? ParticipantDrawerListItemViewModel {
                    DrawerParticipantView(item: participantItem, avatarManager: avatarManager)
                } else {
                    DrawerItemView(item: option)
                }
            }
        }.padding([.bottom, .top], DrawerListConstants.listVerticalPadding)
    }
}

internal struct SelectableDrawerItemView: View {
    let item: SelectableDrawerListItemViewModel

    var body: some View {
        HStack {
            if let startIcon = item.startIcon {
                Icon(name: startIcon, size: DrawerListConstants.iconSize)
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
            if let action = item.action {
                action()
            }

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
    let item: ParticipantDrawerListItemViewModel
    let avatarManager: AvatarViewManagerProtocol

    var body: some View {
        HStack {
            // Placeholder replaced with actual avatar view
            CompositeAvatar(
                displayName: Binding.constant(item.participantInfoModel.displayName),
                avatarImage: Binding.constant(
                    item.participantInfoModel.isRemoteUser ?
                    avatarManager.avatarStorage.value(forKey: item.participantInfoModel.userIdentifier)?.avatarImage :
                        avatarManager.localParticipantViewData?.avatarImage
                ),
                isSpeaking: false,
                avatarSize: .size40
            )
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            if !item.participantInfoModel.isRemoteUser {
                Text("(ME)")
            }
            Spacer()
            Icon(name: item.participantInfoModel.isMuted ? .micOff : .micOn, size: DrawerListConstants.iconSize)
        }
        .onTapGesture {
            guard let action = item.action else {
                return
            }
            action()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }
}

internal class DrawerListConstants {
    static let iconSize: CGFloat = 24
    static let textPaddingLeading: CGFloat = 8
    static let optionPaddingVertical: CGFloat = 12
    static let optionPaddingHorizontal: CGFloat = 16
    static let listVerticalPadding: CGFloat = 12
}

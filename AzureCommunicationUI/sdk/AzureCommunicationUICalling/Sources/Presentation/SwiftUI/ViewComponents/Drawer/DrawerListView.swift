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
    let sections: [DrawerListSection]

    // We don't always need this, but we do for Participants or whenever we show an Avatar
    // Provides just in case
    let avatarManager: AvatarViewManagerProtocol

    @State
    private var scrollViewContentSize: CGSize = .zero

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                ForEach(0..<sections.count, id: \.self) { sectionIndex in
                    let section = sections[sectionIndex]

                    if let header = section.header {
                        Section(header: inflateView(for: header, avatarManager: avatarManager)) {
                            ForEach(0..<section.items.count, id: \.self) { itemIndex in
                                let item = section.items[itemIndex]
                                inflateView(for: item, avatarManager: avatarManager)
                            }
                        }
                    } else {
                        ForEach(0..<section.items.count, id: \.self) { itemIndex in
                            let item = section.items[itemIndex]
                            inflateView(for: item, avatarManager: avatarManager)
                        }
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

    func inflateView(for item: BaseDrawerItemViewModel, avatarManager: AvatarViewManagerProtocol) -> some View {
        if let selectableItem = item as? SelectableDrawerListItemViewModel {
            return AnyView(SelectableDrawerItemView(item: selectableItem))
        } else if let titleItem = item as? TitleDrawerListItemViewModel {
            return AnyView(DrawerTitleView(item: titleItem))
        } else if let bodyItem = item as? BodyTextDrawerListItemViewModel {
            return AnyView(DrawerBodyTextView(item: bodyItem))
        } else if let participantItem = item as? ParticipantsListCellViewModel {
            return AnyView(DrawerParticipantView(item: participantItem, avatarManager: avatarManager))
        } else if let drawerItem = item as? DrawerListItemViewModel {
            return AnyView(DrawerItemView(item: drawerItem))
        }
        return AnyView(EmptyView())
    }
}

internal struct DrawerListSection {
    let header: BaseDrawerItemViewModel?
    let items: [BaseDrawerItemViewModel]
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

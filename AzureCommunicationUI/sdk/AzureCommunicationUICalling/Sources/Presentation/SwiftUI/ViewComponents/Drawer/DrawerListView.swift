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
internal struct DrawerListView: View {
    let sections: [DrawerListSection]

    // We don't always need this, but we do for Participants or whenever we show an Avatar
    // Provides just in case
    let avatarManager: AvatarViewManagerProtocol

    @State
    private var scrollViewContentSize: CGSize = .zero

    var body: some View {
        let halfScreenHeight = UIScreen.main.bounds.height * 0.5

        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                ForEach(0..<sections.count, id: \.self) { sectionIndex in
                    let section = sections[sectionIndex]

                    if let header = section.header {
                        Section(header: inflateView(for: header, avatarManager: avatarManager)
                            .accessibilityElement(children: .combine)) {
                            ForEach(0..<section.items.count, id: \.self) { itemIndex in
                                let item = section.items[itemIndex]
                                inflateView(for: item, avatarManager: avatarManager)
                                    .accessibilityElement(children: .combine)
                            }
                        }
                    } else {
                        ForEach(0..<section.items.count, id: \.self) { itemIndex in
                            let item = section.items[itemIndex]
                            inflateView(for: item, avatarManager: avatarManager)
                                .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
            .padding([.bottom, .top], DrawerListConstants.listVerticalPadding)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            DispatchQueue.main.async {
                                scrollViewContentSize = geometry.size
                            }
                        }
                        .onChange(of: geometry.size) { _ in
                            DispatchQueue.main.async {
                                withAnimation {
                                    scrollViewContentSize = geometry.size
                                }
                            }
                        }
                }
            )
        }
        .frame(maxHeight: min(scrollViewContentSize.height, halfScreenHeight))
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
        } else if let drawerItem = item as? BodyTextWithActionDrawerListItemViewModel {
            return AnyView(DrawerBodyWithActionTextView(item: drawerItem))
        }
        return AnyView(EmptyView())
    }
}

internal struct DrawerListSection {
    let header: BaseDrawerItemViewModel?
    let items: [BaseDrawerItemViewModel]
}

internal class DrawerListConstants {
    static let iconSize: CGFloat = 24
    static let textPaddingLeading: CGFloat = 8
    static let optionPaddingVertical: CGFloat = 12
    static let participantOptionPaddingVertical: CGFloat = 4
    static let optionPaddingHorizontal: CGFloat = 16
    static let listVerticalPadding: CGFloat = 12
    static let micIconOpacity: CGFloat = 0.5
}

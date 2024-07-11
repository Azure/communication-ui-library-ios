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

internal struct SelectableDrawerItemView: View {
    let item: SelectableDrawerListItemViewModel

    var body: some View {
        HStack {
            Icon(name: item.icon, size: DrawerListConstants.iconSize)
                .foregroundColor(.primary)

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
        .contentShape(Rectangle())
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .background(Color(StyleProvider.color.surface))
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
        .contentShape(Rectangle())
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .background(Color(StyleProvider.color.surface))
    }
}

internal struct DrawerBodyWithActionTextView: View {
    let item: BodyTextWithActionDrawerListItemViewModel
    @State
    var isConfirming = false

    var body: some View {
        HStack {
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            Spacer()
            Text(item.actionText)
                .onTapGesture {
                   isConfirming = true
                }
                .foregroundColor(Color(StyleProvider.color.primaryColor))
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .background(Color(StyleProvider.color.surface))
        .confirmationDialog(
            Text(item.confirmAccept),
            isPresented: $isConfirming,
            titleVisibility: .automatic) {
            Button(item.actionText) {
                isConfirming = false
                item.accept()
            }.foregroundColor(Color(StyleProvider.color.primaryColor))
            Button(item.confirmDeny, role: .destructive) {
                isConfirming = false
                item.deny()
            }
            Button("Cancel", role: .cancel) {
                isConfirming = false
            }.foregroundColor(Color(StyleProvider.color.primaryColor))
        }
    }
}

internal struct DrawerParticipantView: View {
    let item: ParticipantsListCellViewModel
    let avatarManager: AvatarViewManagerProtocol
    @State
    var isConfirming = false

    var body: some View {
        let participantViewData = item.getParticipantViewData(from: avatarManager)
        let name = item.getParticipantName(with: participantViewData)
        let displayName = item.getCellDisplayName(with: participantViewData)

        HStack {
            // Placeholder replaced with actual avatar view
            CompositeAvatar(
                displayName: Binding.constant(name),
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
            if item.isHold {
                Text("On Hold")
            } else {
                Icon(name: item.isMuted ? .micOff : .micOn,
                     size: DrawerListConstants.iconSize)
                .opacity(DrawerListConstants.micIconOpacity)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.participantOptionPaddingVertical)
        .accessibilityIdentifier(item.getCellAccessibilityLabel(with: participantViewData))
        .onTapGesture {
            // Is this participant is set up to confirm, lets toggle that
            if item.confirmTitle != nil && item.confirmAccept != nil && item.confirmDeny != nil {
                isConfirming = true
            } else {
                // Else, we are going to just do the "accept()" action by default
                guard let action = item.accept else {
                    return
                }
                action()
            }
        }
        .fullScreenCover(isPresented: $isConfirming) {
            CustomAlert(
                title: item.confirmTitle ?? "",
                message: "Are you sure you want to proceed?",
                dismiss: {
                    isConfirming = false
                },
                content: {
                    Button(action: {
                        guard let accept = item.accept else {
                            return
                        }
                        accept()
                        isConfirming = false
                    }, label: {
                        Text(item.confirmAccept ?? "")
                    })
                    Button(action: {
                        guard let deny = item.deny else {
                            return
                        }
                        deny()
                        isConfirming = false
                    }, label: {
                        Text(item.confirmDeny ?? "")
                    }).onChange(of: item.confirmAccept) { _ in
                        if item.confirmAccept == "" {
                            isConfirming = false
                        }
                    }

                })
            .background(BackgroundCleanerView())

        }
        .transaction { transaction in
            transaction.disablesAnimations = true
            // transaction.animation = .linear(duration: 1)
        }
    }
}

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CustomAlert<Content: View>: View {
    let title: String
    let message: String
    let dismiss: () -> Void
    let content: Content

    init(title: String, message: String, dismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.message = message
        self.content = content()
        self.dismiss = dismiss
    }

    var body: some View {
            ZStack {
                Color.black.opacity(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        dismiss()
                    }
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        VStack {
                            Text(title).font(.headline)
                            Text(message).padding(.vertical)
                            HStack {
                                content
                            }
                        }.padding()
                        .background(Color(StyleProvider.color.surface))
                        .cornerRadius(10)
                        .shadow(radius: 10)

                        Spacer()
                    }
                    Spacer()
                }
            }
    }
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
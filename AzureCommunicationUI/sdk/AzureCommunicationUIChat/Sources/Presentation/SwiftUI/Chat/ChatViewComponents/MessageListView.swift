//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageListView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 0
        static let topPadding: CGFloat = 8
        static let topConsecutivePadding: CGFloat = 4

        static let defaultMinListRowHeight: CGFloat = 10
    }

    @State private var scrollOffset: CGFloat = .zero
    @State private var scrollSize: CGFloat = .zero

    @StateObject var viewModel: MessageListViewModel

    var body: some View {
        messageList
    }

    var messageList: some View {
        ScrollViewReader { scrollProxy in
            ObservableScrollView(
                offsetChanged: {
                    scrollOffset = $0
                    print("Scroll Offset: \(scrollOffset)")
                    print("Scroll Size: \(scrollSize)")
                    print("Is at Bottom: \(isAtBottom())")
                },
                heightChanged: { scrollSize = $0 },
                content: {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, _ in
                        let messageViewModel = viewModel.createViewModel(index: index)
                        MessageView(viewModel: messageViewModel)
                        .id(index)
                        .padding(getEdgeInsets(message: messageViewModel))
                    }
                }
                })
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Constants.defaultMinListRowHeight)
            .onChange(of: viewModel.haveInitialMessagesLoaded) { _ in
                if viewModel.haveInitialMessagesLoaded {
                    scrollToBottom(proxy: scrollProxy)
                }
            }
            .onChange(of: viewModel.messages.count) { _ in
                if isAtBottom() || viewModel.isLocalUser(message: viewModel.messages.last) {
                    scrollToBottom(proxy: scrollProxy)
                } else {
                    // New messages
                    // Calculate number of messages
                    // Show button

                    // Paged messages
                    // Ignore
                }
            }
        }
    }

    var jumpToBottomButton: some View {
        Button(action: onJumpToBottom)
    }

    func onJumpToButton() {
        print("Jump to bottom")
    }

    // 1. Scroll to bottom when you send message (Done)
    // 2. Scroll to bottom when receiving a new message and already at bottom
    // 3. Scroll unchanged when receiving a new message and not at bottom (Done)
    // 4. Scroll unchanged when paging in new messages
    // 5. Add button to scroll to new messages
    // 6. When resuming, do not scroll (Done)

    // If scroll is near the bottom then we want to scroll to bottom with new messages coming in
    // If not don't scroll, this handles case where we page near top

    // Must find full height of scroll view

    private func isAtBottom() -> Bool {
        let scrollTolerance: CGFloat = 50
        return scrollSize - scrollOffset < scrollTolerance
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        let scrollIndex = viewModel.messages.count - 1
        print("SCROLL TO: \(scrollIndex)") // Testing
        proxy.scrollTo(scrollIndex)
    }

    private func getEdgeInsets(message: MessageViewModel) -> EdgeInsets {
        EdgeInsets(
            top: message.isConsecutive
            ? Constants.topConsecutivePadding
            : Constants.topPadding,
            leading: Constants.horizontalPadding,
            bottom: Constants.bottomPadding,
            trailing: Constants.horizontalPadding)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct ScrollHeightPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat {0}
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ObservableScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let offsetChanged: (CGFloat) -> Void
    let heightChanged: (CGFloat) -> Void
    let content: Content

    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGFloat) -> Void = { _ in },
        heightChanged: @escaping (CGFloat) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.heightChanged = heightChanged
        self.content = content()
    }

    var body: some View {
        SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: -geometry.frame(in: .named("scrollView")).origin.y
                )
            }
            content
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(key: ScrollHeightPreferenceKey.self, value: geometry.size.height)
                }
            )
        }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: ScrollHeightPreferenceKey.self, value: -geometry.size.height)
            })
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
        .onPreferenceChange(ScrollHeightPreferenceKey.self, perform: heightChanged)
    }
}

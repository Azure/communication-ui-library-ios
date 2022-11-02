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
                offsetChanged: { scrollOffset = $0 },
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
                    // Check latest message timestamp, compare to latest read message
                    // Subtract indicies to get number of new messages
                    // Show jump to bottom button with number of messages

                    // Paged messages will be ignored as they won't change the latest message timestamp
                }
            }
        }
    }

    private func isAtBottom() -> Bool {
        let scrollTolerance: CGFloat = 50
        return scrollSize - scrollOffset < scrollTolerance
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        let scrollIndex = viewModel.messages.count - 1
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

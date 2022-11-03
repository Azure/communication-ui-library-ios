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
        static let buttonBottomPadding: CGFloat = 35
        static let defaultMinListRowHeight: CGFloat = 10
    }

    @StateObject var viewModel: MessageListViewModel

    var body: some View {
        ZStack {
            messageList
            jumpToNewMessagesButton
        }
    }

    var messageList: some View {
        ScrollViewReader { scrollProxy in
            ObservableScrollView(
                offsetChanged: { viewModel.scrollOffset = $0 },
                heightChanged: { viewModel.scrollSize = $0 },
                content: {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, _ in
                            let messageViewModel = viewModel.createViewModel(index: index)
                            MessageView(viewModel: messageViewModel)
                            .id(index)
                            .padding(getEdgeInsets(message: messageViewModel))
                            .onAppear {
                                if index == viewModel.minFetchIndex {
                                    viewModel.fetchMessages()
                                }
                            }
                        }
                    }
                })
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Constants.defaultMinListRowHeight)
            .onChange(of: viewModel.shouldScrollToBottom) { _ in
                if viewModel.shouldScrollToBottom {
                    scrollToBottom(proxy: scrollProxy)
                    viewModel.shouldScrollToBottom = false
                }
            }
        }
    }

    var jumpToNewMessagesButton: some View {
        Group {
            if viewModel.showJumpToNewMessages {
                VStack {
                    Spacer()
                    PrimaryButton(viewModel: viewModel.jumpToNewMessagesButtonViewModel)
                        .fixedSize()
                        .padding(Constants.buttonBottomPadding)
                }
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        let scrollIndex = viewModel.messages.count - 1
        proxy.scrollTo(scrollIndex, anchor: .bottom)
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

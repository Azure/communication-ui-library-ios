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

        static let minFetchIndex: Int = 40
    }
    private let sendReadReceiptInterval: Double = 5.0
    @State private var sendReadReceiptTimer: Timer?
    @State private var lastReadMessageIndex: Int?

    @StateObject var viewModel: MessageListViewModel

    var body: some View {
        messageList
    }

    var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, _ in
                        let messageViewModel = viewModel.createViewModel(index: index)
                        MessageView(viewModel: messageViewModel)
                            .id(index)
                        // .listRowSeparator(.hidden) // Use List when bug is resolved
                        // .listRowInsets(getEdgeInsets(message: messageViewModel)) // Use List when bug is resolved
                            .padding(getEdgeInsets(message: messageViewModel))
                            .onAppear {
                                // Need a more consistent way of triggering a fetch
                                // Don't scroll automatically when triggering a fetch
                                // Pull to refresh?
                                // Activity Indicator
                                if index == Constants.minFetchIndex {
                                    viewModel.fetchMessages()
                                }

                                guard let lastReadMessageIndex = self.lastReadMessageIndex else {
                                    self.lastReadMessageIndex = index
                                    return
                                }
                                if index > lastReadMessageIndex {
                                    self.lastReadMessageIndex = index
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, Constants.defaultMinListRowHeight)
                .onAppear {
                    sendReadReceiptTimer = Timer.scheduledTimer(withTimeInterval: sendReadReceiptInterval,
                                                                repeats: true) { _ in
                        viewModel.sendReadReceipt(messageIndex: lastReadMessageIndex)
                    }
                    scrollToBottom(proxy: proxy, bottomIndex: viewModel.messages.count)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    scrollToBottom(proxy: proxy, bottomIndex: viewModel.messages.count)
                }
                .onDisappear {
                    sendReadReceiptTimer?.invalidate()
                }
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy, bottomIndex: Int) {
        guard bottomIndex != 0 else {
            return
        }
        let scrollIndex = bottomIndex - 1
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

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
    private let sendReadReceiptInterval: Double = 5.0
    @State private var sendReadReceiptTimer: Timer?
    @State private var lastReadMessageIndex: Int?

    @StateObject var viewModel: MessageListViewModel

    var body: some View {
        if #available(iOS 15, *) {
            messageList
        } else {
            legacyMessageList
        }
    }

    @available(iOS 15.0, *)
    var messageList: some View {
        ScrollViewReader { _ in
            List {
                ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, message in
                    MessageView(viewModel: message)
                    .id(index)
                    .listRowSeparator(.hidden)
                    .listRowInsets(getEdgeInsets(message: message))
                    .onAppear {
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
            }
            .onDisappear {
                sendReadReceiptTimer?.invalidate()
            }
        }
    }

    // iOS 14
    var legacyMessageList: some View {
        ScrollViewReader { value in
            LazyVStack {
                ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, message in
                    MessageView(viewModel: message)
                    .id(index)
                    .onAppear {
                        guard let lastReadMessageIndex = self.lastReadMessageIndex else {
                            self.lastReadMessageIndex = index
                            return
                        }
                        if index > lastReadMessageIndex {
                            self.lastReadMessageIndex = index
                        }
                    }
                }
                .onChange(of: viewModel.messages.count) { _ in
                    value.scrollTo(viewModel.messages.count - 1)
                }
            }
            .onAppear {
                sendReadReceiptTimer = Timer.scheduledTimer(withTimeInterval: sendReadReceiptInterval,
                                                            repeats: true) { _ in
                    viewModel.sendReadReceipt(messageIndex: lastReadMessageIndex)
                }
            }
            .onDisappear {
                sendReadReceiptTimer?.invalidate()
            }
        }
    }

    func getEdgeInsets(message: MessageViewModel) -> EdgeInsets {
        EdgeInsets(
            top: message.isConsecutive
            ? Constants.topConsecutivePadding
            : Constants.topPadding,
            leading: Constants.horizontalPadding,
            bottom: Constants.bottomPadding,
            trailing: Constants.horizontalPadding)
    }
}

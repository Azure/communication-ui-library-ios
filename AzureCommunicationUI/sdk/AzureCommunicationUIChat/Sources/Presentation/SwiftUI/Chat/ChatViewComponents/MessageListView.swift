//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct MessageListView: View {
    private enum Constants {
        static let defaultMinListRowHeight: CGFloat = 10

        static let buttonIconSize: CGFloat = 24
        static let buttonShadowRadius: CGFloat = 7
        static let buttonShadowOffset: CGFloat = 4
        static let buttonBottomPadding: CGFloat = 20

        static let messageSendStatusIconSize: CGFloat = 12
        static let messageSendStatusViewPadding: CGFloat = 3
    }

    @StateObject var viewModel: MessageListViewModel

    var body: some View {
        ZStack {
            messageList
            initialFetchActivityIndicator
            jumpToNewMessagesButton
        }
        .onTapGesture {
            UIApplicationHelper.dismissKeyboard()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    var initialFetchActivityIndicator: some View {
        Group {
            if !viewModel.hasFetchedInitialMessages {
                ActivityIndicator(size: .large)
                    .isAnimating(true)
                    .padding()
            }
        }
    }

    var previousFetchActivityIndicator: some View {
        Group {
            if !viewModel.hasFetchedPreviousMessages &&
                !viewModel.hasExhaustedPreviousMessages {
                ActivityIndicator(size: .large)
                    .isAnimating(true)
                    .padding()
            }
        }
    }

    var messageList: some View {
        ScrollViewReader { scrollProxy in
            ObservableScrollView(
                showsIndicators: false, // Hide scroll indicator due to swiftUI issue where it jumps around
                offsetChanged: {
                    viewModel.startDidEndScrollingTimer(currentOffset: $0)
                    viewModel.scrollOffset = $0
                },
                heightChanged: { viewModel.scrollSize = $0 },
                content: {
                    LazyVStack(spacing: 0) {
                        Section(footer: previousFetchActivityIndicator) {
                            ForEach(viewModel.messages.reversed()) { message in
                                HStack(spacing: Constants.messageSendStatusViewPadding) {
                                    createMessage(message: message, messages: viewModel.messages)
                                        .onAppear {
                                            viewModel.fetchMessages(lastSeenMessage: message)
                                            viewModel.updateReadReceiptToBeSentMessageId(message: message)
                                            viewModel.messageIdsOnScreen.append(message.id)
                                        }
                                        .onDisappear {
                                            viewModel.messageIdsOnScreen.removeAll { $0 == message.id }
                                        }
                                    createMessageSendStatus(message: message)
                                }
                            }
                            .flippedUpsideDown()
                        }
                    }
                })
            .flippedUpsideDown()
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Constants.defaultMinListRowHeight)
            .onChange(of: viewModel.shouldScrollToBottom) { _ in
                scrollToBottom(proxy: scrollProxy)
            }
            .onChange(of: viewModel.shouldScrollToId) { _ in
                scrollToId(proxy: scrollProxy)
            }
        }.onReceive(keyboardWillShow) { _ in
            viewModel.shouldScrollToBottom = true
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if viewModel.shouldScrollToBottom {
            if let lastMessageId = viewModel.messages.last?.id {
                withAnimation(.linear(duration: 0.1)) {
                    proxy.scrollTo(lastMessageId, anchor: .bottom)
                }
                if viewModel.scrollSize < UIScreen.main.bounds.size.height {
                    viewModel.startDidEndScrollingTimer(currentOffset: nil)
                }
            }
            viewModel.shouldScrollToBottom = false
        }
    }

    // Keep scroll location when receiving messages
    private func scrollToId(proxy: ScrollViewProxy) {
        if viewModel.shouldScrollToId {
            let lastMessageIndex = viewModel.messageIdsOnScreen.count - 2 < 0
            ? 0
            : viewModel.messageIdsOnScreen.count - 2
            let lastMessageId = viewModel.messageIdsOnScreen[lastMessageIndex]
            proxy.scrollTo(lastMessageId, anchor: .bottom)
            viewModel.shouldScrollToId = false
        }
    }

    var jumpToNewMessagesButton: some View {
        Group {
            if viewModel.showJumpToNewMessages {
                VStack {
                    Spacer()
                    Button(action: {
                        viewModel.jumpToNewMessagesButtonTapped()
                    }, label: {
                        HStack {
                            Icon(name: .downArrow, size: Constants.buttonIconSize)
                            Text(viewModel.jumpToNewMessagesButtonLabel)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(StyleProvider.color.primaryColor))
                        .clipShape(Capsule())
                        .shadow(radius: Constants.buttonShadowRadius, y: Constants.buttonShadowOffset)
                        .padding(.bottom, Constants.buttonBottomPadding)
                    })
                }
            }
        }
    }

    @ViewBuilder
    private func createMessage(message: ChatMessageInfoModel,
                               messages: [ChatMessageInfoModel]) -> some View {
        let index = messages.firstIndex(where: { $0 == message }) ?? 0
        let lastMessageIndex = index == 0 ? 0 : index - 1
        let lastMessage = messages[lastMessageIndex]
        let showDateHeader = index == 0 || message.createdOn.dayOfYear - lastMessage.createdOn.dayOfYear > 0
        let isConsecutive = message.senderId == lastMessage.senderId
        let showUsername = !message.isLocalUser && !isConsecutive
        let showTime = !isConsecutive
        let showMessageStatus = viewModel.shouldShowMessageStatusView(message: message)

        MessageView(messageModel: message,
                    showDateHeader: showDateHeader,
                    isConsecutive: isConsecutive,
                    showUsername: showUsername,
                    showTime: showTime,
                    showMessageStatus: showMessageStatus)
    }

    @ViewBuilder
    private func createMessageSendStatus(message: ChatMessageInfoModel) -> some View {
        let shouldShowMessageStatusView = viewModel.shouldShowMessageStatusView(message: message)
        let tintColor = message.sendStatus == .failed
                        ? StyleProvider.color.dangerPrimary : StyleProvider.color.primaryColor
        VStack {
            Spacer()
            if message.isLocalUser,
               message.type == .text,
               shouldShowMessageStatusView,
               let iconName = message.getIconNameForMessageSendStatus() {
                StyleProvider.icon.getImage(for: iconName)
                    .frame(width: Constants.messageSendStatusIconSize,
                           height: Constants.messageSendStatusIconSize)
                    .foregroundColor(Color(tintColor))
                    .padding([.bottom, .trailing], Constants.messageSendStatusViewPadding)
            }
        }
    }
}

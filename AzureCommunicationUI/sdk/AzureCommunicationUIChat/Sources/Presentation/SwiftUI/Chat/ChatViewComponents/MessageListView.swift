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
            activityIndicator
            messageList
            jumpToNewMessagesButton
        }
        .onTapGesture {
            UIApplicationHelper.dismissKeyboard()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    var activityIndicator: some View {
        Group {
            if viewModel.showActivityIndicator {
                VStack {
                    Spacer()
                    ActivityIndicator(size: .large)
                        .isAnimating(true)
                    Spacer()
                }
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
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, message in
                            HStack(spacing: Constants.messageSendStatusViewPadding) {
                                createMessage(message: message, messages: viewModel.messages, index: index)
                                .onAppear {
                                    viewModel.fetchMessages(index: index)
                                    viewModel.updateReadReceiptToBeSentMessageId(message: message)
                                }
                                createMessageSendStatus(message: message)
                            }
                            .id(index)
                        }
                    }
                })
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Constants.defaultMinListRowHeight)
            .onChange(of: viewModel.shouldScrollToBottom) { _ in
                if viewModel.shouldScrollToBottom {
                    let lastIndex = viewModel.messages.count - 1 > 0 ? viewModel.messages.count - 1 : 0
                    scrollProxy.scrollTo(lastIndex, anchor: .bottom)
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
                               messages: [ChatMessageInfoModel],
                               index: Int) -> some View {
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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct MessageListView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 0
        static let topPadding: CGFloat = 8
        static let topConsecutivePadding: CGFloat = 4
        static let defaultMinListRowHeight: CGFloat = 10
        static let localUserMessageTrailingPadding: CGFloat = 3

        static let buttonIconSize: CGFloat = 24
        static let buttonShadowRadius: CGFloat = 7
        static let buttonShadowOffset: CGFloat = 4
        static let buttonBottomPadding: CGFloat = 20
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
                offsetChanged: {
                    viewModel.startDidEndScrollingTimer(currentOffset: $0)
                    viewModel.scrollOffset = $0
                },
                heightChanged: { viewModel.scrollSize = $0 },
                content: {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, message in
                            createMessage(message: message, messages: viewModel.messages, index: index)
                            .onAppear {
                                viewModel.fetchMessages(index: index)
                                viewModel.updateReadReceiptToBeSentMessageId(message: message)
                            }
                        }
                    }
                })
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Constants.defaultMinListRowHeight)
            .onChange(of: viewModel.shouldScrollToBottom) { _ in
                if viewModel.shouldScrollToBottom {
                    if let lastMessage = viewModel.messages.last {
                        scrollProxy.scrollTo(lastMessage, anchor: .bottom)
                    }
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
        let showMessageStatus = viewModel.latestSeenMessageId == message.id

        let edgeInsets = EdgeInsets(top: isConsecutive
                                        ? Constants.topConsecutivePadding
                                        : Constants.topPadding,
                                    leading: Constants.horizontalPadding,
                                    bottom: Constants.bottomPadding,
                                    trailing: message.isLocalUser
                                        ? Constants.localUserMessageTrailingPadding
                                        : Constants.horizontalPadding)

        MessageView(messageModel: message,
                    showDateHeader: showDateHeader,
                    isConsecutive: isConsecutive,
                    showUsername: showUsername,
                    showTime: showTime,
                    showMessageStatus: showMessageStatus)
        .padding(edgeInsets)
    }
}

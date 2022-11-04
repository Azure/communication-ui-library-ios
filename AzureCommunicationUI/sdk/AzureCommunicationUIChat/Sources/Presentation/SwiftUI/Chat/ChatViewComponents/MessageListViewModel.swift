//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageListViewModel: ObservableObject {
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let logger: Logger
    private let dispatch: ActionDispatch
    private let sendReadReceiptInterval: Double = 5.0
    private let scrollTolerance: CGFloat = 50

    private var repositoryUpdatedTimestamp: Date = .distantPast
    private var localUserId: String?
    private var latestMessageId: String?
    private var sendReadReceiptTimer: Timer?
    private(set) var lastReadMessageIndex: Int?

    let minFetchIndex: Int = 40

    var scrollOffset: CGFloat = .zero
    var scrollSize: CGFloat = .zero
    var jumpToNewMessagesButtonViewModel: PrimaryButtonViewModel!

    @Published var messages: [ChatMessageInfoModel]
    @Published var haveInitialMessagesLoaded: Bool = false
    @Published var showJumpToNewMessages: Bool = false
    @Published var shouldScrollToBottom: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         messageRepositoryManager: MessageRepositoryManagerProtocol,
         logger: Logger,
         chatState: ChatState,
         dispatch: @escaping ActionDispatch) {
        self.messageRepositoryManager = messageRepositoryManager
        self.logger = logger
        self.dispatch = dispatch
        self.localUserId = chatState.localUser?.id // Only take in local User ID?
        self.messages = messageRepositoryManager.messages

        jumpToNewMessagesButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: jumpToNewMessagesLabel,
            iconName: .downArrow,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.jumpToNewMessagesButtonTapped()
        }
//      .update(accessibilityLabel: self.localizationProvider.getLocalizedString(.jumpToNewMessages))
    }

    private var numberOfNewMessages: Int {
        (messages.count - 1) - (lastReadMessageIndex ?? 0)
    }

    private var jumpToNewMessagesLabel: String {
        numberOfNewMessages < 100
        ? "\(numberOfNewMessages) new messages"
        : "99+ new messages"
    }

    private func isLocalUser(message: ChatMessageInfoModel?) -> Bool {
        guard message != nil else {
            return false
        }
        return message!.senderId == localUserId
    }

    private func isAtBottom() -> Bool {
        return scrollSize - scrollOffset < scrollTolerance
    }

    func jumpToNewMessagesButtonTapped() {
        shouldScrollToBottom = true
    }

    func fetchMessages() {
        dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
    }

    func update(repositoryState: RepositoryState) {
        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            messages = messageRepositoryManager.messages

            // Scroll for initial load of messages
            // Hide messages and show activity indicator?
            if !haveInitialMessagesLoaded && messages.count > 1 {
                shouldScrollToBottom = true
                haveInitialMessagesLoaded = true
            }

            // Scroll to new message
            if messages.last?.id != latestMessageId {
                latestMessageId = messages.last?.id
                shouldScrollToBottom = isLocalUser(message: messages.last) || isAtBottom()
            }

            if numberOfNewMessages > 0 {
                showJumpToNewMessages = true
            }

            jumpToNewMessagesButtonViewModel.update(buttonLabel: jumpToNewMessagesLabel)
        }
    }

    // Replace with factory
    func createViewModel(index: Int) -> MessageViewModel {
        let message = messages[index]
        let type = messages[index].type
        let lastMessageIndex = index == 0 ? 0 : index - 1
        let lastMessage = messages[lastMessageIndex]
        let showDateHeader = index == 0 || message.createdOn.dayOfYear - lastMessage.createdOn.dayOfYear > 0
        let isConsecutive = message.senderId == lastMessage.senderId

        switch type {
        case .text:
            let isLocalUser = isLocalUser(message: message)
            let showUsername = !isLocalUser && !isConsecutive
            let showTime = !isConsecutive

            return TextMessageViewModel(message: message,
                                        showDateHeader: showDateHeader,
                                        showUsername: showUsername,
                                        showTime: showTime,
                                        isLocalUser: isLocalUser,
                                        isConsecutive: isConsecutive)
        case .participantsAdded, .participantsRemoved, .topicUpdated:
            return SystemMessageViewModel(message: message,
                                          showDateHeader: showDateHeader,
                                          isConsecutive: false)
        case .html:
            return HtmlMessageViewModel(message: message, showDateHeader: showDateHeader, isConsecutive: isConsecutive)
        case .custom(_): // Stub until finished
            return SystemMessageViewModel(message: message,
                                          showDateHeader: showDateHeader,
                                          isConsecutive: isConsecutive)
        }
    }

    func updateLastReadMessageIndex(index: Int) {
        guard index >= 0, index < messages.count else {
            return
        }
        let message = messages[index]
        /* There will be messages that do not have senderId, such as system messages
         For those messages, we still want to send read receipt
         That's why we default senderId to empty string, which will pass the guard statement senderId != localUserId */
        let senderId = message.senderId ?? ""
        guard let localUserId = localUserId, senderId != localUserId else {
            return
        }
        guard let lastReadMessageIndex = self.lastReadMessageIndex else {
            self.lastReadMessageIndex = index
            return
        }
        if index > lastReadMessageIndex {
            self.lastReadMessageIndex = index
        }
    }

    func messageListAppeared() {
        sendReadReceiptTimer = Timer.scheduledTimer(withTimeInterval: sendReadReceiptInterval,
                                                    repeats: true) { [weak self]_ in
            self?.sendReadReceipt(messageIndex: self?.lastReadMessageIndex)
        }
    }

    func messageListDisappeared() {
        sendReadReceiptTimer?.invalidate()
    }

    func sendReadReceipt(messageIndex: Int?) {
        guard let messageIndex = messageIndex, messageIndex >= 0, messageIndex < messages.count else {
            return
        }
        let messageId = messages[messageIndex].id
        dispatch(.participantsAction(.sendReadReceiptTriggered(messageId: messageId)))
    }

    deinit {
        sendReadReceiptTimer?.invalidate()
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreGraphics

class MessageListViewModel: ObservableObject {
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let logger: Logger
    private let dispatch: ActionDispatch
    private let sendReadReceiptInterval: Double = 5.0
    private let scrollTolerance: CGFloat = 50

    private var repositoryUpdatedTimestamp: Date = .distantPast
    private var lastReceivedMessageId: String?
    private var lastSentMessageId: String?
    private var hasFetchedInitialMessages: Bool = false
    private var localUserId: String?
    private var sendReadReceiptTimer: Timer?

    private(set) var lastReadMessageId: String?

    let minFetchIndex: Int = 40

    var scrollOffset: CGFloat = .zero
    var scrollSize: CGFloat = .zero
    var jumpToNewMessagesButtonViewModel: PrimaryButtonViewModel!

    @Published var messages: [ChatMessageInfoModel]

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
            buttonLabel: "",
            iconName: .downArrow,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.jumpToNewMessagesButtonTapped()
        }
//      .update(accessibilityLabel: self.localizationProvider.getLocalizedString(.jumpToNewMessages))
    }

    // Localization
    private func getJumpToNewMessagesLabel(numberOfNewMessages: Int) -> String {
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

    func isAtBottom() -> Bool {
        return scrollSize - scrollOffset < scrollTolerance
    }

    func jumpToNewMessagesButtonTapped() {
        shouldScrollToBottom = true
    }

    func fetchMessages() {
        dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
    }

    func updateLastReadMessageId(message: ChatMessageInfoModel, index: Int) {
        guard !isLocalUser(message: message) else {
            return
        }
        if Int(message.id) ?? 0 > Int(lastReadMessageId) ?? 0 {
            self.lastReadMessageId = message.id
        }
    }

    func messageListAppeared() {
        sendReadReceiptTimer = Timer.scheduledTimer(withTimeInterval: sendReadReceiptInterval,
                                                    repeats: true) { [weak self]_ in
            self?.sendReadReceipt(messageId: self?.lastReadMessageId)
        }
    }

    func messageListDisappeared() {
        sendReadReceiptTimer?.invalidate()
    }

    func sendReadReceipt(messageId: String?) {
        guard let messageId = messageId else {
            return
        }
        dispatch(.participantsAction(.sendReadReceiptTriggered(messageId: messageId)))
    }

    func update(chatState: ChatState, repositoryState: RepositoryState) {
        // Scroll to new received message
        if self.lastReceivedMessageId != chatState.lastReceivedMessageId {
            self.lastReceivedMessageId = chatState.lastReceivedMessageId
            shouldScrollToBottom = isAtBottom()
        }

        // Scroll to new sent message
        if self.lastSentMessageId != chatState.lastSentMessageId {
            self.lastSentMessageId = chatState.lastSentMessageId
            shouldScrollToBottom = true
        }

        // Scroll to bottom for initial messages
        if self.hasFetchedInitialMessages != repositoryState.hasFetchedInitialMessages {
            self.hasFetchedInitialMessages = repositoryState.hasFetchedInitialMessages
            shouldScrollToBottom = true
        }

        // Caculate number of unread messages
        if let lastReadIndex = messages.firstIndex(where: { $0.id == lastReadMessageId }),
           let lastSentIndex = messages.firstIndex(where: { $0.id == lastSentMessageId }) {
            let lastIndex = max(lastReadIndex, lastSentIndex)

            let numberOfUnreadMessages = (messages.count - 1) - lastIndex
            print("SCROLL: \(numberOfUnreadMessages)")
        }

        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            messages = messageRepositoryManager.messages

            // Scroll for initial load of messages
            // Hide messages and show activity indicator?
//            if !haveInitialMessagesLoaded && messages.count > 1 {
//                shouldScrollToBottom = true
//                haveInitialMessagesLoaded = true
//            }

//            if let index = messages.firstIndex(where: { $0.id == lastReadMessageId }) {
//                let numberOfNewMessages = (messages.count - 1) - (index)
//                showJumpToNewMessages = numberOfNewMessages > 0
//                jumpToNewMessagesButtonViewModel.update(
//                    buttonLabel: getJumpToNewMessagesLabel(numberOfNewMessages: numberOfNewMessages))
//                print("SCROLL - Number of new messages: \(numberOfNewMessages)")
//            }
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

    deinit {
        sendReadReceiptTimer?.invalidate()
    }
}

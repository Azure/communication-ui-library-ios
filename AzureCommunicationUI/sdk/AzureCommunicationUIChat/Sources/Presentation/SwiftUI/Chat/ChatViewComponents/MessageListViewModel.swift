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
    private var lastReceivedMessageTimestamp: Date = .distantPast
    private var lastSentMessageTimestamp: Date = .distantPast
    private var hasFetchedInitialMessages: Bool = false
    private var localUserId: String?
    private var sendReadReceiptTimer: Timer?
    private(set) var lastSentReadReceiptMessageId: String?

    let minFetchIndex: Int = 40

    var scrollOffset: CGFloat = .zero
    var scrollSize: CGFloat = .zero

    @Published var messages: [ChatMessageInfoModel]
    @Published var showActivityIndicator: Bool = true
    @Published var showJumpToNewMessages: Bool = false
    @Published var jumpToNewMessagesButtonLabel: String = ""
    @Published var shouldScrollToBottom: Bool = false
    @Published var showMessageSendStatusIconMessageId: String?
    @Published var messageSendStatusIconType: MessageSendStatus?

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
    }

    // Localization
    private func getJumpToNewMessagesLabel(numberOfNewMessages: Int) -> String {
        switch numberOfNewMessages {
        case 100..<Int.max:
            return "99+ new messages"
        case 2..<99:
            return "\(numberOfNewMessages) new messages"
        case 1:
            return "\(numberOfNewMessages) new message"
        default:
            return "Unknown number of new messages"
        }
    }

    func isLocalUser(message: ChatMessageInfoModel?) -> Bool {
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

    func updateLastSentReadReceiptMessageId(message: ChatMessageInfoModel) {
        guard !isLocalUser(message: message) else {
            return
        }
        if Int(message.id) ?? 0 > Int(lastSentReadReceiptMessageId) ?? 0 {
            self.lastSentReadReceiptMessageId = message.id
            updateJumpToNewMessages()
        }
    }

    func messageListAppeared() {
        sendReadReceiptTimer = Timer.scheduledTimer(withTimeInterval: sendReadReceiptInterval,
                                                    repeats: true) { [weak self]_ in
            self?.sendReadReceipt(messageId: self?.lastSentReadReceiptMessageId)
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
        // Update messages
        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            messages = messageRepositoryManager.messages
            updateShowMessageSendStatusIconMessageId()
        }

        // Scroll to new received message
        if self.lastReceivedMessageTimestamp < chatState.lastReceivedMessageTimestamp {
            self.lastReceivedMessageTimestamp = chatState.lastReceivedMessageTimestamp
            shouldScrollToBottom = isAtBottom()
        }

        // Scroll to bottom for initial messages
        if self.hasFetchedInitialMessages != repositoryState.hasFetchedInitialMessages {
            self.hasFetchedInitialMessages = repositoryState.hasFetchedInitialMessages
            showActivityIndicator = false
            shouldScrollToBottom = true
            showMessageSendStatusIconMessageId = messageRepositoryManager.messages.last(where: {
                $0.senderId == localUserId
            })?.id
            messageSendStatusIconType = .seen
        }

        // Scroll to new sent message
        if self.lastSentMessageTimestamp < chatState.lastSentMessageTimestamp {
            self.lastSentMessageTimestamp = chatState.lastSentMessageTimestamp
            shouldScrollToBottom = true
        }

        updateJumpToNewMessages()
    }

    func getNumberOfNewMessages() -> Int {
        if let lastReadIndex = messages.firstIndex(where: { $0.id == lastSentReadReceiptMessageId }),
           let lastSentIndex = messages.lastIndex(where: { isLocalUser(message: $0) }) {
            let lastIndex = max(lastReadIndex, lastSentIndex)

             return (messages.count - 1) - lastIndex
        }
        return 0
    }

    func updateJumpToNewMessages() {
        let numberOfNewMessages = getNumberOfNewMessages()
        showJumpToNewMessages = numberOfNewMessages > 0
        jumpToNewMessagesButtonLabel = getJumpToNewMessagesLabel(numberOfNewMessages: numberOfNewMessages)
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
        case .text, .html:
            let isLocalUser = isLocalUser(message: message)
            let showUsername = !isLocalUser && !isConsecutive
            let showTime = !isConsecutive
            let showMessageSendStatusIcon = message.id == showMessageSendStatusIconMessageId

            return TextMessageViewModel(message: message,
                                        showDateHeader: showDateHeader,
                                        showUsername: showUsername,
                                        showTime: showTime,
                                        isLocalUser: isLocalUser,
                                        isConsecutive: isConsecutive,
                                        showMessageSendStatusIcon: showMessageSendStatusIcon,
                                        messageSendStatusIconType: messageSendStatusIconType)
        case .participantsAdded, .participantsRemoved, .topicUpdated:
            return SystemMessageViewModel(message: message,
                                          showDateHeader: showDateHeader,
                                          isConsecutive: false)
        case .custom(_): // Stub until finished
            return SystemMessageViewModel(message: message,
                                          showDateHeader: showDateHeader,
                                          isConsecutive: isConsecutive)
        }
    }

    func updateShowMessageSendStatusIconMessageId() {
        for message in messages.reversed() where message.sendStatus != nil && message.senderId == localUserId {
            showMessageSendStatusIconMessageId = message.id
            messageSendStatusIconType = message.sendStatus
            return
        }
    }

    deinit {
        sendReadReceiptTimer?.invalidate()
    }
}

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
    private let scrollEndsTolerance: CGFloat = 1
    private let scrollTolerance: CGFloat = 50

    private var repositoryUpdatedTimestamp: Date = .distantPast
    private var lastReceivedMessageTimestamp: Date = .distantPast
    private var lastSentMessageTimestamp: Date = .distantPast
    private var lastSentReadReceiptTimestamp: Date = .distantPast
    private var hasFetchedInitialMessages: Bool = false
    private var didEndScrollingTimer: Timer?
    private var readReceiptToBeSentMessageId: String?

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
         dispatch: @escaping ActionDispatch) {
        self.messageRepositoryManager = messageRepositoryManager
        self.logger = logger
        self.dispatch = dispatch
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

    func isAtBottom() -> Bool {
        return scrollSize - scrollOffset < scrollTolerance
    }

    func jumpToNewMessagesButtonTapped() {
        shouldScrollToBottom = true
    }

    func fetchMessages() {
        dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
    }

    func updateReadReceiptToBeSentMessageId(message: ChatMessageInfoModel) {
        guard !message.isLocalUser else {
            return
        }
        guard readReceiptToBeSentMessageId != nil else {
            self.readReceiptToBeSentMessageId = message.id
            return
        }
        if let messageTimestamp = message.id.convertEpochStringToTimestamp(),
           let toBeSentReadReceiptTimestamp = readReceiptToBeSentMessageId?.convertEpochStringToTimestamp(),
           messageTimestamp > toBeSentReadReceiptTimestamp {
            self.readReceiptToBeSentMessageId = message.id
            updateJumpToNewMessages()
        }
    }

    func startDidEndScrollingTimer(currentOffset: CGFloat) {
        guard currentOffset != scrollOffset else {
            return
        }
        if didEndScrollingTimer != nil {
            didEndScrollingTimer?.invalidate()
        }
        didEndScrollingTimer = Timer.scheduledTimer(
            withTimeInterval: scrollEndsTolerance,
            repeats: false) { [weak self]_ in
            self?.sendReadReceipt(messageId: self?.readReceiptToBeSentMessageId)
        }
    }

    func sendReadReceipt(messageId: String?) {
        guard let messageId = messageId,
            let toBeSentReadReceiptTimestamp = messageId.convertEpochStringToTimestamp(),
            toBeSentReadReceiptTimestamp > lastSentReadReceiptTimestamp else {
            return
        }
        dispatch(.participantsAction(.sendReadReceiptTriggered(messageId: messageId)))
        lastSentReadReceiptTimestamp = toBeSentReadReceiptTimestamp
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
                $0.isLocalUser
            })?.id
            messageSendStatusIconType = .seen
        }

        // Scroll to new sent message
        if self.lastSentMessageTimestamp < chatState.lastSentMessageTimestamp {
            self.lastSentMessageTimestamp = chatState.lastSentMessageTimestamp
            shouldScrollToBottom = true
        }

        if self.lastSentReadReceiptTimestamp == .distantPast, self.readReceiptToBeSentMessageId != nil {
            sendReadReceipt(messageId: self.readReceiptToBeSentMessageId)
        }

        updateJumpToNewMessages()
    }

    func getNumberOfNewMessages() -> Int {
        if let lastReadIndex = messages.firstIndex(where: { $0.id == readReceiptToBeSentMessageId }),
           let lastSentIndex = messages.lastIndex(where: { $0.isLocalUser }) {
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
            let showUsername = !message.isLocalUser && !isConsecutive
            let showTime = !isConsecutive
            let showMessageSendStatusIcon = message.id == showMessageSendStatusIconMessageId

            return TextMessageViewModel(message: message,
                                        showDateHeader: showDateHeader,
                                        showUsername: showUsername,
                                        showTime: showTime,
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
        for message in messages.reversed() where message.sendStatus != nil && message.isLocalUser {
            showMessageSendStatusIconMessageId = message.id
            messageSendStatusIconType = message.sendStatus
            return
        }
    }

    deinit {
        didEndScrollingTimer?.invalidate()
    }
}

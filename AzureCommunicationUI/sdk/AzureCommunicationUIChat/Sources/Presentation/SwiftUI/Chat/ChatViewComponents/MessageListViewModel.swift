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
    private var lastSendingMessageTimestamp: Date = .distantPast
    private var lastSentOrFailedMessageTimestamp: Date = .distantPast
    private var lastSentReadReceiptTimestamp: Date = .distantPast
    private var hasFetchedInitialMessages: Bool = false
    private var didEndScrollingTimer: Timer?
    private var readReceiptToBeSentMessageId: String?
    private var lastReadReceiptReceivedTimestamp: Date = .distantPast

    let minFetchIndex: Int = 40

    var scrollOffset: CGFloat = .zero
    var scrollSize: CGFloat = .zero

    @Published var messages: [ChatMessageInfoModel]
    @Published var showActivityIndicator: Bool = true
    @Published var showJumpToNewMessages: Bool = false
    @Published var jumpToNewMessagesButtonLabel: String = ""
    @Published var shouldScrollToBottom: Bool = false
    @Published var latestSeenMessageId: String?
    @Published var latestSendingOrSentMessageId: String?

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
            return "99+ new messages" // Localization
        case 2..<99:
            return "\(numberOfNewMessages) new messages" // Localization
        case 1:
            return "\(numberOfNewMessages) new message" // Localization
        default:
            return "Unknown number of new messages" // Localization
        }
    }

    func isAtBottom() -> Bool {
        return scrollSize - scrollOffset < scrollTolerance
    }

    func jumpToNewMessagesButtonTapped() {
        shouldScrollToBottom = true
    }

    func fetchMessages(index: Int) {
        if index == minFetchIndex {
            dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
        }
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
                // Assume all messages are seen by others when re-joining the chat
                if let latestSeenMessage = messages.last {
                    latestSeenMessageId = latestSeenMessage.id
                }
            }

            // Scroll to new sending message and get latest sending message id
            if self.lastSendingMessageTimestamp < chatState.lastSendingMessageTimestamp {
                self.lastSendingMessageTimestamp = chatState.lastSendingMessageTimestamp
                shouldScrollToBottom = true
                if let latestSendingMessage = messages.last(where: {$0.sendStatus == .sending}) {
                    latestSendingOrSentMessageId = latestSendingMessage.id
                }
            }

            // Get latest sent message id
            if self.lastSentOrFailedMessageTimestamp < chatState.lastSentOrFailedMessageTimestamp {
                self.lastSentOrFailedMessageTimestamp = chatState.lastSentOrFailedMessageTimestamp
                if let latestSentMessage = messages.last(where: {$0.sendStatus == .sent}) {
                    latestSendingOrSentMessageId = latestSentMessage.id
                }
            }

            // Send read receipt when initial screen is loaded
            if self.lastSentReadReceiptTimestamp == .distantPast, self.readReceiptToBeSentMessageId != nil {
                sendReadReceipt(messageId: self.readReceiptToBeSentMessageId)
            }

            // Get latest seen message
            if self.lastReadReceiptReceivedTimestamp < chatState.lastReadReceiptReceivedTimestamp {
                self.lastReadReceiptReceivedTimestamp = chatState.lastReadReceiptReceivedTimestamp
                if let latestSeenMessage = messages.last(where: {$0.sendStatus == .seen}) {
                    latestSeenMessageId = latestSeenMessage.id
                }
            }

            updateJumpToNewMessages()
        }
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

    func shouldShowMessageStatusView(message: ChatMessageInfoModel) -> Bool {
        let messageFailed = message.sendStatus == .failed
        let showLatestSeenMessage = latestSeenMessageId == message.id
        let showLatestSendingOrSentMessage = latestSendingOrSentMessageId == message.id
        return messageFailed || showLatestSeenMessage || showLatestSendingOrSentMessage
    }

    deinit {
        didEndScrollingTimer?.invalidate()
    }
}

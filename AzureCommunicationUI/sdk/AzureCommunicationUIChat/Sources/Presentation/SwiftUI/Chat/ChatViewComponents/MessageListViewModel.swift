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
    private var didEndScrollingTimer: Timer?
    private var readReceiptToBeSentMessageId: String?
    private var lastReadReceiptReceivedTimestamp: Date = .distantPast

    let minFetchIndex: Int = 40

    var scrollOffset: CGFloat = .zero
    var scrollSize: CGFloat = .zero

    @Published var messages: [ChatMessageInfoModel]
    @Published var hasFetchedInitialMessages: Bool = false
    @Published var hasFetchedPreviousMessages: Bool = true
    @Published var showJumpToNewMessages: Bool = false
    @Published var jumpToNewMessagesButtonLabel: String = ""
    @Published var shouldScrollToBottom: Bool = false
    @Published var shouldScrollToId: Bool = false
    @Published var latestSeenMessageId: String?
    @Published var latestSendingOrSentMessageId: String?
    @Published var messageIdsOnScreen: [String] = []

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

    func fetchMessages(lastSeenMessage: ChatMessageInfoModel) {
        if let lastSeenMessageIndex = messages.firstIndex(where: { $0.id == lastSeenMessage.id }),
            lastSeenMessageIndex <= minFetchIndex && hasFetchedPreviousMessages {
            hasFetchedPreviousMessages = false
            dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
        }
    }

    func updateReadReceiptToBeSentMessageId(message: ChatMessageInfoModel) {
        guard !message.isLocalUser,
              message.type != .participantsAdded,
              message.type != .participantsRemoved,
              message.type != .topicUpdated else {
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

    func startDidEndScrollingTimer(currentOffset: CGFloat?) {
        guard currentOffset == nil || currentOffset != scrollOffset else {
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
                shouldScrollToId = !isAtBottom()
            }

            // Check if initial messages have been fetched
            if self.hasFetchedInitialMessages != repositoryState.hasFetchedInitialMessages {
                self.hasFetchedInitialMessages = repositoryState.hasFetchedInitialMessages

                // Assume all messages are seen by others when re-joining the chat
                if let latestSeenMessage = messages.last(where: {$0.isLocalUser}) {
                    latestSeenMessageId = latestSeenMessage.id
                }
            }

            // Check if previous messages have been fetched
            if self.hasFetchedPreviousMessages != repositoryState.hasFetchedPreviousMessages {
                self.hasFetchedPreviousMessages = repositoryState.hasFetchedPreviousMessages
            }

            // Scroll to new sending message and get latest sending message id
            if let lastSendingMessageTimestamp = chatState.lastSendingMessageTimestamp,
               self.lastSendingMessageTimestamp < lastSendingMessageTimestamp {
                self.lastSendingMessageTimestamp = lastSendingMessageTimestamp
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
        let messageList = messages.filter {
            $0.type != .topicUpdated && $0.type != .participantsRemoved && $0.type != .participantsAdded
        }
        if let lastReadIndex = messageList.firstIndex(where: { $0.id == readReceiptToBeSentMessageId }),
           let lastSentIndex = messageList.lastIndex(where: { $0.isLocalUser }) {
            let lastIndex = max(lastReadIndex, lastSentIndex)
            return (messageList.count - 1) - lastIndex
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

    func onDisappear() {
        didEndScrollingTimer?.invalidate()
    }
}

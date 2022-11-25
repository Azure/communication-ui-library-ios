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

    func updateLastSentReadReceiptMessageId(message: ChatMessageInfoModel) {
        guard !message.isLocalUser else {
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

    deinit {
        sendReadReceiptTimer?.invalidate()
    }
}

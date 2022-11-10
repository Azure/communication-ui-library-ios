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
    private var repositoryUpdatedTimestamp: Date = .distantPast
    private var localUserId: String? // Remove optional?
    private var sendReadReceiptTimer: Timer?
    private var lastReadMessageIndex: Int?

    @Published var showReadIconIndex: Int?
    @Published var messages: [ChatMessageInfoModel]

    init(messageRepositoryManager: MessageRepositoryManagerProtocol,
         logger: Logger,
         chatState: ChatState,
         dispatch: @escaping ActionDispatch) {
        self.messageRepositoryManager = messageRepositoryManager
        self.logger = logger
        self.dispatch = dispatch
        self.localUserId = chatState.localUser?.id // Only take in local User ID?
        self.messages = messageRepositoryManager.messages
    }

    func fetchMessages() {
        print("SCROLL: Fetch Messages") // Testing
        dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
    }

    func update(repositoryState: RepositoryState) {
        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            messages = messageRepositoryManager.messages

            for (index, message) in messageRepositoryManager.messages.enumerated().reversed() {
                guard message.senderId == localUserId else {
                    return
                }
                switch message.messageSendStatus {
                case .seen:
                    showReadIconIndex = index
                    return
                default:
                    continue
                }
            }

            // Debug for testing
//            print("*Messages count: \(messageRepositoryManager.messages.count)")
//            for message in messageRepositoryManager.messages {
//                print("--*Messages: \(message.id) \(String(describing: message.content))")
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
            let isLocalUser = message.senderId == localUserId
            let showUsername = !isLocalUser && !isConsecutive
            let showTime = !isConsecutive
            let showReadIcon = index == showReadIconIndex

            return TextMessageViewModel(message: message,
                                        showDateHeader: showDateHeader,
                                        showUsername: showUsername,
                                        showTime: showTime,
                                        isLocalUser: isLocalUser,
                                        isConsecutive: isConsecutive,
                                        showReadIcon: showReadIcon)
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

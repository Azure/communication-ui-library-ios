//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageListViewModel: ObservableObject {
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let logger: Logger
    private let dispatch: ActionDispatch

    private var repositoryUpdatedTimestamp: Date = .distantPast
    private var localUserId: String? // Remove optional?
    private var lastReadMessageIndex: Int?

    @Published var messages: [ChatMessageInfoModel]
    @Published var haveInitialMessagesLoaded: Bool = false
    @Published var showJumpToNewMessages: Bool = false

    init(messageRepositoryManager: MessageRepositoryManagerProtocol,
         logger: Logger,
         dispatch: @escaping ActionDispatch,
         chatState: ChatState) {
        self.messageRepositoryManager = messageRepositoryManager
        self.logger = logger
        self.dispatch = dispatch

        self.localUserId = chatState.localUser?.id // Only take in local User ID?
        self.messages = messageRepositoryManager.messages
    }

    var numberOfNewMessages: Int {
        (messages.count - 1) - (lastReadMessageIndex ?? 0)
    }

    func fetchMessages() {
        print("SCROLL: Fetch Messages") // Testing
        dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
    }

    func update(repositoryState: RepositoryState) {
        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            messages = messageRepositoryManager.messages

            if !haveInitialMessagesLoaded {
                haveInitialMessagesLoaded = true
            }

            if numberOfNewMessages > 0 {
                showJumpToNewMessages = true
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

    // Move the message repo?
    func isLocalUser(message: ChatMessageInfoModel?) -> Bool {
        guard message != nil else {
            return false
        }
        return message!.senderId == localUserId
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageListViewModel: ObservableObject {
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let logger: Logger

    private var repositoryUpdatedTimestamp: Date = .distantPast
    private var localUserId: String? // Remove optional?

    @Published var messages: [MessageViewModel] = []

    init(messageRepositoryManager: MessageRepositoryManagerProtocol,
         logger: Logger,
         chatState: ChatState) {
        self.messageRepositoryManager = messageRepositoryManager
        self.logger = logger

        self.localUserId = chatState.localUser?.id // Only take in local User ID?
    }

    func update(repositoryState: RepositoryState) {
        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            messages = []
            print("*Messages count: \(messageRepositoryManager.messages.count)") // for testing
            for (index, message) in messageRepositoryManager.messages.enumerated() {
                print("--*Messages: \(message.id) \(String(describing: message.content))")
                messages.append(createViewModel(messages: messageRepositoryManager.messages, index: index))
            }
        }
    }

    // Replace with factory
    func createViewModel(messages: [ChatMessageInfoModel], index: Int) -> MessageViewModel {
        let message = messages[index]
        let lastMessageIndex = index == 0 ? 0 : index - 1
        let lastMessage = messages[lastMessageIndex]
        let showDateHeader = index == 0 || message.createdOn.dayOfYear - lastMessage.createdOn.dayOfYear > 0
        let isConsecutive = message.senderId == lastMessage.senderId

        if messages[index].type == .text {
            let isLocalUser = message.senderId == localUserId
            let showUsername = !isLocalUser && !isConsecutive
            let showTime = !isConsecutive

            return TextMessageViewModel(message: message,
                                    showDateHeader: showDateHeader,
                                    showUsername: showUsername,
                                    showTime: showTime,
                                    isLocalUser: isLocalUser,
                                    isConsecutive: isConsecutive)
        } else {
            return SystemMessageViewModel(message: message,
                                          showDateHeader: showDateHeader,
                                          isConsecutive: isConsecutive)
        }
    }
}

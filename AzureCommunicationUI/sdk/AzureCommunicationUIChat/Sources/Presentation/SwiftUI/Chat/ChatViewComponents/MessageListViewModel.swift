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
            // for testing
            messages = []
            print("*Messages count: \(messageRepositoryManager.messages.count)")
            for (index, message) in messageRepositoryManager.messages.enumerated() {
                print("--*Messages: \(message.id) \(String(describing: message.content))")
                messages.append(createViewModel(messages: messageRepositoryManager.messages, index: index))
            }
        }
    }

    func createViewModel(messages: [ChatMessageInfoModel], index: Int) -> MessageViewModel {

        let message = messages[index]

        if messages[index].type == .text {
            let lastMessageIndex = index == 0 ? 0 : index - 1
            let lastMessage = messages[lastMessageIndex]
            let isLocalUser = message.senderId == localUserId
            let showUsername = !isLocalUser && lastMessage.senderId ?? "" != message.senderId ?? ""
            let showTime = lastMessage.senderId ?? "" != message.senderId ?? ""
            let showDateHeader = true // lastMessage.createdOn?.dayOfYear != message.createdOn?.dayOfYear,

            return TextMessageViewModel(message: message,
                                    showUsername: showUsername,
                                    showTime: showTime,
                                    showDateHeader: showDateHeader,
                                    isLocalUser: isLocalUser)
        } else {
            // System
            return SystemMessageViewModel(message: message)
        }
    }
}

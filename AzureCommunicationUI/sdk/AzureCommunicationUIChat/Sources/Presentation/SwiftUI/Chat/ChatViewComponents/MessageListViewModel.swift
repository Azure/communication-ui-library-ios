//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageListViewModel: ObservableObject {
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let logger: Logger

    private var repositoryUpdatedTimestamp: Date = .distantPast

    @Published var messages: [MessageViewModel] = []

    init(messageRepositoryManager: MessageRepositoryManagerProtocol,
         logger: Logger) {
        self.messageRepositoryManager = messageRepositoryManager
        self.logger = logger
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
        let localUserIdentifier = "INSERT LOCAL USER ID" // REPLACE

        let lastMessage = messages[index - 1]

        let message = messages[index]
        let isLocalUser = message.senderId == localUserIdentifier
        let showUsername = !isLocalUser && lastMessage.senderId ?? "" != message.senderId ?? ""
        let showTime = lastMessage.senderId ?? "" != message.senderId ?? ""
        let showDateHeader = true // lastMessage.createdOn?.dayOfYear != message.createdOn?.dayOfYear,

        return TextMessageViewModel(message: message,
                                showUsername: showUsername,
                                showTime: showTime,
                                showDateHeader: showDateHeader,
                                isLocalUser: isLocalUser)
    }
}

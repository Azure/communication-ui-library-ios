//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
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

        messages.append(MessageViewModel())
        messages.append(MessageViewModel())
        messages.append(MessageViewModel())
    }

    func update(repositoryState: RepositoryState) {
        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            // for testing
            print("*Messages count: \(messageRepositoryManager.messages.count)")
            for m in messageRepositoryManager.messages {
                print("--*Messages: \(m.id) \(m.content)")
            }
//            self.messages = messageRepositoryManager.messages.toMessageViewModel
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ThreadViewModel: ObservableObject {
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
            for _ in messageRepositoryManager.messages {
                messages.append(MessageViewModel())
            }
//            self.messages = messageRepositoryManager.messages.toMessageViewModel
        }
    }
}

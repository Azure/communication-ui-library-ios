//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol RepositoryMiddlewareHandling {
    func loadInitialMessages(messages: [ChatMessageInfoModel]) -> Task<Void, Never>
}

class RepositoryMiddlewareHandler: RepositoryMiddlewareHandling {
    private let messageRepository: MessageRepositoryManagerProtocol
    private let logger: Logger

    init(messageRepository: MessageRepositoryManagerProtocol, logger: Logger) {
        self.messageRepository = messageRepository
        self.logger = logger
    }

    func loadInitialMessages(messages: [ChatMessageInfoModel]) -> Task<Void, Never> {
        Task {
            messageRepository.addInitialMessages(initialMessages: messages)
        }
    }
}

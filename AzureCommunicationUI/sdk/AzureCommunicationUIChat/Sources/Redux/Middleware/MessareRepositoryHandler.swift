//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol MessageRepositoryMiddlewareHandling {
    // local event
    func loadInitialMessage(messages: [ChatMessageInfoModel])
}

class MessageRepositoryMiddlewareHandler: MessageRepositoryMiddlewareHandling {
    private let messageRepository: MessageRepositoryManagerProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()

    init(messageRepository: MessageRepositoryManagerProtocol, logger: Logger) {
        self.messageRepository = messageRepository
        self.logger = logger
    }

    func loadInitialMessage(messages: [ChatMessageInfoModel]) {
        messageRepository.addInitialMessages(initialMessages: messages)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol ChatServiceEventHandling {
    func subscription(dispatch: @escaping ActionDispatch)
}

class ChatServiceEventHandler: ChatServiceEventHandling {
    private let chatService: ChatServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    func subscription(dispatch: @escaping ActionDispatch) {
        logger.debug("Subscribe to chat service subjects")

        chatService.chatEventSubject
            .sink { [weak self] chatEvent in
                let eventType = chatEvent.eventType
                let infoModel = chatEvent.infoModel

                switch (eventType, infoModel) {
                case (.chatMessageReceived,
                      let chatMessage as ChatMessageInfoModel):
                    self?.handleChatMessageReceived(dispatch: dispatch, chatMessage: chatMessage)
                // add more cases here
                default:
                    print("ChatServiceEventHandler subscription switch: default case")
                }
            }.store(in: cancelBag)
    }

    func handleChatMessageReceived(dispatch: @escaping ActionDispatch,
                                   chatMessage: ChatMessageInfoModel) {
        dispatch(.repositoryAction(.chatMessageReceived(message: chatMessage)))
    }

}

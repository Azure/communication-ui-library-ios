//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import AzureCommunicationCommon

protocol ChatServiceListening {
    func subscription(dispatch: @escaping ActionDispatch)
}

class ChatServiceListener: ChatServiceListening {
    private let chatService: ChatServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    func subscription(dispatch: @escaping ActionDispatch) {
        logger.debug("Subscribe to calling service subjects")

        chatService.typingIndicatorSubject
            .sink { userEventTimestampModel in
                dispatch(.participantsAction(.typingIndicatorReceived(userEventTimestamp: userEventTimestampModel)))
            }.store(in: subscription)

        chatService.readReceiptSubject
            .sink { userEventTimestampModel in
                dispatch(.participantsAction(.messageReadReceived(userEventTimestamp: userEventTimestampModel)))
            }.store(in: subscription)

        chatService.chatMessageReceivedSubject
            .sink { chatMessageModel in
                dispatch(.chatAction(.messageReceived(message: chatMessageModel)))
            }.store(in: subscription)

        chatService.chatMessageEditedSubject
            .sink { chatMessageModel in
                dispatch(.chatAction(.messageEditReceived(message: chatMessageModel)))
            }.store(in: subscription)

        chatService.chatMessageDeletedSubject
            .sink { chatMessageModel in
                dispatch(.chatAction(.messageDeleteReceived(message: chatMessageModel)))
            }.store(in: subscription)

        chatService.chatThreadTopicSubject
            .sink { topic in
                dispatch(.chatAction(.topicUpdateReceived(topic: topic)))
            }.store(in: subscription)

        chatService.chatThreadDeletedSubject
            .sink { threadId in
                dispatch(.chatThreadDeletedReceived(threadId: threadId))
            }.store(in: subscription)

        chatService.participantsAddedSubject
            .sink { participants in
                dispatch(.participantsAction(.participantsAddedReceived(participants: participants)))
            }.store(in: subscription)

        chatService.participantsRemovedSubject
            .sink { participants in
                dispatch(.participantsAction(.participantsRemovedReceived(participants: participants)))
            }.store(in: subscription)
    }
}

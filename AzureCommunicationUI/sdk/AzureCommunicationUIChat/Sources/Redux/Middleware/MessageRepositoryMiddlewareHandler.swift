//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import AzureCommunicationCommon

protocol MessageRepositoryMiddlewareHandling {
    // local event
    func loadInitialMessage(messages: [ChatMessageInfoModel])
    func fetchPreviousMessage(messages: [ChatMessageInfoModel])
    // dummy message
    func sendMessage(message: ChatMessageInfoModel)
    func sendMessageSuccess(message: ChatMessageInfoModel)

    // receiving events
    func messageReceived(message: ChatMessageInfoModel)
    func messageEditedReceived(message: ChatMessageInfoModel)
    func messageDeleteReceived(message: ChatMessageInfoModel)
    func sendMessageRetry(message: ChatMessageInfoModel)
    func topicUpdatedReceived(topic: String)
    func participantsAddedReceived(participants: [ParticipantInfoModel])
    func participantsRemovedReceived(participants: [ParticipantInfoModel])
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

    func fetchPreviousMessage(messages: [ChatMessageInfoModel]) {
        messageRepository.addPreviousMessages(previousMessages: messages)
    }

    func sendMessage(message: ChatMessageInfoModel) {
        messageRepository.addNewSendMessage(message: message)
    }

    func sendMessageSuccess(message: ChatMessageInfoModel) {
        messageRepository.updateNewSendMessageId(newMessage: message)
    }

    func messageReceived(message: ChatMessageInfoModel) {
        messageRepository.addReceivedMessage(message: message)
    }

    func messageEditedReceived(message: ChatMessageInfoModel) {
        messageRepository.replaceEditedMessage(message: message)
    }

    func messageDeleteReceived(message: ChatMessageInfoModel) {
        messageRepository.removeDeletedMessage(message: message)
    }

    func sendMessageRetry(message: ChatMessageInfoModel) {
        messageRepository.replaceSendMessageRetry(message: message)
    }

    func topicUpdatedReceived(topic: String) {
        messageRepository.addTopicSystemMessage(newTopic: topic)
    }

    func participantsAddedReceived(participants: [ParticipantInfoModel]) {
        messageRepository.addParticipantsAddedSystemMessage(participants: participants)
    }

    func participantsRemovedReceived(participants: [ParticipantInfoModel]) {
        messageRepository.addParticipantsRemovedSystemMessage(participants: participants)
    }
}

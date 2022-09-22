//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

protocol MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] { get }

    // local event
    func addInitialMessages(initialMessages: [ChatMessageInfoModel])
    func addPreviousMessages(previousMessages: [ChatMessageInfoModel])
    // dummy message
    func addNewSendMessage(message: ChatMessageInfoModel)
    func updateNewSendMessageId(newMessage: ChatMessageInfoModel)

    // receiving events
    func addReceivedMessage(message: ChatMessageInfoModel)
    func replaceEditedMessage(message: ChatMessageInfoModel)
    func removeDeletedMessage(message: ChatMessageInfoModel)
    func replaceSendMessageRetry(message: ChatMessageInfoModel)
    func addTopicSystemMessage(newTopic: String)
    func addParticipantsAddedSystemMessage(participants: [ParticipantInfoModel])
    func addParticipantsRemovedSystemMessage(participants: [ParticipantInfoModel])
}

class MessageRepositoryManager: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    func addInitialMessages(initialMessages: [ChatMessageInfoModel]) {
        messages = initialMessages
    }

    func addPreviousMessages(previousMessages: [ChatMessageInfoModel]) {
        messages = previousMessages + messages
    }

    func addNewSendMessage(message: ChatMessageInfoModel) {
        messages.append(message)
    }

    func updateNewSendMessageId(newMessage: ChatMessageInfoModel) {
        if let index = messages.firstIndex(where: {
            $0.internalId == newMessage.internalId
        }) {
            messages[index] = newMessage
        }
    }

    func addReceivedMessage(message: ChatMessageInfoModel) {
        if let index = messages.firstIndex(where: {
            $0.id == message.id || $0.internalId == message.internalId
        }) {
            messages[index] = message
        } else {
            messages.append(message)
        }
    }

    func replaceEditedMessage(message: ChatMessageInfoModel) {
        print("not implemented")
    }

    func removeDeletedMessage(message: ChatMessageInfoModel) {
        print("not implemented")
    }

    func replaceSendMessageRetry(message: ChatMessageInfoModel) {
        print("not implemented")
    }

    func addTopicSystemMessage(newTopic: String) {
        let topicUpdatedMessage = ChatMessageInfoModel(
            id: UUID().uuidString,
            type: .topicUpdated,
            content: "Topic has been updated to: `\(newTopic)`",
            createdOn: Iso8601Date()
        )
        messages.append(topicUpdatedMessage)
    }

    func addParticipantsAddedSystemMessage(participants: [ParticipantInfoModel]) {
        let participantAddedMessage = ChatMessageInfoModel(
            id: UUID().uuidString,
            type: .participantsAdded,
            createdOn: Iso8601Date(),
            participants: participants
        )
        messages.append(participantAddedMessage)
    }

    func addParticipantsRemovedSystemMessage(participants: [ParticipantInfoModel]) {
        let participantAddedMessage = ChatMessageInfoModel(
            id: UUID().uuidString,
            type: .participantsRemoved,
            createdOn: Iso8601Date(),
            participants: participants
        )
        messages.append(participantAddedMessage)
    }
}

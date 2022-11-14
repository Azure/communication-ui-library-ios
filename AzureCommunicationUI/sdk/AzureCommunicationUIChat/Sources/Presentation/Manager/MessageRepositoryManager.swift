//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

protocol MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] { get }

    // MARK: sending local events
    func addInitialMessages(initialMessages: [ChatMessageInfoModel])
    func addPreviousMessages(previousMessages: [ChatMessageInfoModel])
    func addNewSendingMessage(message: ChatMessageInfoModel)
    func replaceMessageId(internalId: String, actualId: String)
    func addLocalUserRemovedMessage()

    // MARK: participant events
    func addParticipantAdded(message: ChatMessageInfoModel)
    func addParticipantRemoved(message: ChatMessageInfoModel)

    // MARK: receiving remote events
    func addTopicUpdatedMessage(chatThreadInfo: ChatThreadInfoModel)
    func addReceivedMessage(message: ChatMessageInfoModel)
    func updateMessageEdited(message: ChatMessageInfoModel)
    func updateMessageDeleted(message: ChatMessageInfoModel)
}

class MessageRepositoryManager: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    private let eventsHandler: ChatComposite.Events

    init(chatCompositeEventsHandler: ChatComposite.Events) {
        self.eventsHandler = chatCompositeEventsHandler
    }

    func addInitialMessages(initialMessages: [ChatMessageInfoModel]) {
        messages = initialMessages
    }

    func addPreviousMessages(previousMessages: [ChatMessageInfoModel]) {
        // Workaround: improve data structure in MessageRepo user story
        for m in previousMessages {
            if let index = messages.firstIndex(where: {
                $0.id == m.id
            }) {
                messages[index] = m
            } else {
                messages.append(m)
            }
        }

        messages.sort { lhs, rhs -> Bool in
            // createdOn does not have milliseconds
            return lhs.createdOn == rhs.createdOn ?
            lhs.id < rhs.id : lhs.createdOn < rhs.createdOn
        }
    }

    func addNewSendingMessage(message: ChatMessageInfoModel) {
        messages.append(message)
    }

    func replaceMessageId(internalId: String, actualId: String) {
        if let index = messages.firstIndex(where: {
            $0.id == internalId
        }) {
            var msg = messages[index]
            msg.replace(id: actualId)
            messages[index] = msg
        }
    }

    func addParticipantAdded(message: ChatMessageInfoModel) {
        messages.append(message)
    }

    func addParticipantRemoved(message: ChatMessageInfoModel) {
        messages.append(message)
    }

    func addTopicUpdatedMessage(chatThreadInfo: ChatThreadInfoModel) {
        guard let topic = chatThreadInfo.topic else {
            return
        }
        let topicUpdatedSystemMessage = ChatMessageInfoModel(
            type: .topicUpdated,
            content: topic,
            createdOn: chatThreadInfo.receivedOn
        )
        messages.append(topicUpdatedSystemMessage)
    }

    func addLocalUserRemovedMessage() {
        let topicUpdatedSystemMessage = ChatMessageInfoModel(
            type: .localUserRemoved,
            createdOn: Iso8601Date()
        )
        messages.append(topicUpdatedSystemMessage)
    }

    func addReceivedMessage(message: ChatMessageInfoModel) {
        if let index = messages.firstIndex(where: {
            $0.id == message.id
        }) {
            messages[index] = message
        } else {
            messages.append(message)
        }
    }

    func updateMessageEdited(message: ChatMessageInfoModel) {
        if let index = messages.firstIndex(where: {
            $0.id == message.id
        }) {
            messages[index] = message
        }
    }

    func updateMessageDeleted(message: ChatMessageInfoModel) {
        if let index = messages.firstIndex(where: {
            $0.id == message.id
        }) {
            messages[index] = message
        }
    }
}

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
    func addNewSendingMessage(message: ChatMessageInfoModel)
    func replaceMessageId(internalId: String, actualId: String)

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

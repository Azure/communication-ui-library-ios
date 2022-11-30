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
    func editMessage(messageId: String, content: String)
    func deleteMessage(messageId: String)
    func replaceMessageId(internalId: String, actualId: String)
    func addLocalUserRemovedMessage()
    func updateEditMessageTimestamp(messageId: String)
    func updateDeletedMessageTimestamp(messageId: String)

    // MARK: participant events
    func addParticipantAdded(message: ChatMessageInfoModel)
    func addParticipantRemoved(message: ChatMessageInfoModel)

    // MARK: receiving remote events
    func addTopicUpdatedMessage(chatThreadInfo: ChatThreadInfoModel)
    func addReceivedMessage(message: ChatMessageInfoModel)
    func updateMessageEdited(message: ChatMessageInfoModel)
    func updateMessageDeleted(message: ChatMessageInfoModel)
    func updateMessageSendStatus(readReceiptInfo: ReadReceiptInfoModel, state: AppState)
}

class MessageRepositoryManager: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    private let eventsHandler: ChatAdapter.Events

    init(chatCompositeEventsHandler: ChatAdapter.Events) {
        self.eventsHandler = chatCompositeEventsHandler
    }

    func addInitialMessages(initialMessages: [ChatMessageInfoModel]) {
        messages = initialMessages
        messages.sort { lhs, rhs -> Bool in
            // createdOn does not have milliseconds
            return lhs.createdOn == rhs.createdOn ?
            lhs.id < rhs.id : lhs.createdOn < rhs.createdOn
        }
        // Assume all previously sent messages have been seen
        if let index = messages.lastIndex(where: {$0.isLocalUser}) {
            messages[index].update(sendStatus: .seen)
        }
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

    func editMessage(messageId: String, content: String) {
        if let index = messages.firstIndex(where: {
            $0.id == messageId
        }) {
            var msg = messages[index]
            msg.edit(content: content)
            msg.update(editedOn: Iso8601Date())
            messages[index] = msg
        }
    }

    func deleteMessage(messageId: String) {
        if let index = messages.firstIndex(where: {
            $0.id == messageId
        }) {
            var msg = messages[index]
            msg.update(deletedOn: Iso8601Date())
            messages[index] = msg
        }
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

    func updateEditMessageTimestamp(messageId: String) {
        if let index = messages.firstIndex(where: {
            $0.id == messageId
        }) {
            var msg = messages[index]
            msg.update(editedOn: Iso8601Date())
            messages[index] = msg
        }
    }

    func updateDeletedMessageTimestamp(messageId: String) {
        if let index = messages.firstIndex(where: {
            $0.id == messageId
        }) {
            var msg = messages[index]
            msg.update(deletedOn: Iso8601Date())
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
        let localUserRemovedSystemMessage = ChatMessageInfoModel(
            type: .participantsRemoved,
            createdOn: Iso8601Date(),
            isLocalUser: true
        )
        messages.append(localUserRemovedSystemMessage)
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

    func updateMessageSendStatus(readReceiptInfo: ReadReceiptInfoModel, state: AppState) {
        guard readReceiptInfo.senderIdentifier.stringValue != state.chatState.localUser?.identifier.stringValue else {
            return
        }
        let messageId = readReceiptInfo.chatMessageId
        let messageTimestamp = messageId.convertEpochStringToTimestamp()
        var readReceiptMap = state.participantsState.readReceiptMap
        readReceiptMap[readReceiptInfo.senderIdentifier.stringValue] = messageTimestamp

        let minimumReadReceiptTimestamp = readReceiptMap.min { $0.value < $1.value }?.value
        guard let minimumReadReceiptTimestamp = minimumReadReceiptTimestamp else {
            return
        }

        guard let messageTimestamp = messageTimestamp,
            messageTimestamp <= minimumReadReceiptTimestamp,
            let index = messages.firstIndex(where: {
                $0.id == messageId
            }) else {
            return
        }

        messages[index].update(sendStatus: .seen)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class MessageRepositoryManagerMocking: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    var addInitialMessagesCalled = false
    var addPreviousMessagesCalled = false
    var addNewSentMessageCalled = false
    var editMessageCalled = false
    var deleteMessageCalled = false
    var replaceMessageIdCalled = false
    var updateEditMessageTimestampCalled = false
    var updateDeletedMessageTimestampCalled = false
    var addReceivedMessageCalled = false
    var addTopicUpdatedMessageCalled = false
    var addParticipantAddedMessageCalled = false
    var addParticipantRemovedMessageCalled = false
    var updateMessageEditedCalled = false
    var updateMessageDeletedCalled = false
    var updateMessageSendStatusCalled = false
    var addlocalUserRemovedMessageCalled = false
    var updateMessageReadReceiptStatusCalled = false

    func addInitialMessages(initialMessages: [ChatMessageInfoModel]) {
        addInitialMessagesCalled = true
        messages = initialMessages
    }

    func addPreviousMessages(previousMessages: [ChatMessageInfoModel]) {
        addPreviousMessagesCalled = true
        messages = previousMessages + messages
    }

    func addNewSendingMessage(message: ChatMessageInfoModel) {
        addNewSentMessageCalled = true
        messages.append(message)
    }

    func editMessage(messageId: String, content: String) {
        editMessageCalled = true
    }

    func deleteMessage(messageId: String) {
        deleteMessageCalled = true
    }

    func replaceMessageId(internalId: String, actualId: String) {
        replaceMessageIdCalled = true
    }

    func updateEditMessageTimestamp(messageId: String) {
        updateEditMessageTimestampCalled = true
    }

    func updateDeletedMessageTimestamp(messageId: String) {
        updateDeletedMessageTimestampCalled = true
    }

    func addTopicUpdatedMessage(chatThreadInfo: ChatThreadInfoModel) {
        addTopicUpdatedMessageCalled = true
    }

    func addParticipantAdded(message: ChatMessageInfoModel) {
        addParticipantAddedMessageCalled = true
        messages.append(message)
    }

    func addParticipantRemoved(message: ChatMessageInfoModel) {
        addParticipantRemovedMessageCalled = true
        messages.append(message)
    }

    func addReceivedMessage(message: ChatMessageInfoModel) {
        addReceivedMessageCalled = true
        messages.append(message)
    }

    func updateMessageEdited(message: ChatMessageInfoModel) {
        updateMessageEditedCalled = true
    }

    func updateMessageDeleted(message: ChatMessageInfoModel) {
        updateMessageDeletedCalled = true
    }

    func updateMessageSendStatus(messageId: String, messageSendStatus: AzureCommunicationUIChat.MessageSendStatus) {
        updateMessageSendStatusCalled = true
    }

    func updateMessageReadReceiptStatus(readReceiptInfo: AzureCommunicationUIChat.ReadReceiptInfoModel, state: ChatAppState) {
        updateMessageReadReceiptStatusCalled = true
    }

    func addLocalUserRemovedMessage() {
        addlocalUserRemovedMessageCalled = true
    }
}

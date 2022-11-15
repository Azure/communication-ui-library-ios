//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class MessageRepositoryManagerMocking: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    var addInitialMessagesCalled: Bool = false
    var addPreviousMessagesCalled: Bool = false
    var addNewSentMessageCalled: Bool = false
    var replaceMessageIdCalled: Bool = false
    var addReceivedMessageCalled: Bool = false
    var addTopicUpdatedMessageCalled: Bool = false
    var addParticipantAddedMessageCalled: Bool = false
    var addParticipantRemovedMessageCalled: Bool = false
    var updateMessageEditedCalled: Bool = false
    var updateMessageDeletedCalled: Bool = false
    var addlocalUserRemovedMessageCalled: Bool = false

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

    func replaceMessageId(internalId: String, actualId: String) {
        replaceMessageIdCalled = true
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

    func addLocalUserRemovedMessage() {
        addlocalUserRemovedMessageCalled = true
    }
}

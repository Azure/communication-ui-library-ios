//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import XCTest
@testable import AzureCommunicationUIChat

class MessageRepositoryManagerTests: XCTestCase {
    var eventsHandler: ChatComposite.Events!

    override func setUp() {
        super.setUp()
        eventsHandler = ChatComposite.Events()
    }

    override func tearDown() {
        super.tearDown()
        eventsHandler = nil
    }

    func test_messageRepositoryManager_addInitialMessages_with_zeroInitialMessages_then_messagesCountWillBeZero() {
        let sut = makeSUT()
        let initialMessages: [ChatMessageInfoModel] = []
        sut.addInitialMessages(initialMessages: initialMessages)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
    }

    func test_messageRepositoryManager_addInitialMessages_with_nonEmptyInitialMessages_then_messagesCountWillBeSame() {
        let sut = makeSUT()
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        sut.addInitialMessages(initialMessages: initialMessages)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
    }

    func test_messageRepositoryManager_addNewSentMessage_when_nonEmptyInitialMessages_then_messagesCountWillBeIncrementByOne() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        let sut = makeSUT(messages: initialMessages)
        let message = ChatMessageInfoModel()
        sut.addNewSendingMessage(message: message)
        XCTAssertEqual(sut.messages.count, initialMessages.count + 1)
    }

    func test_messageRepositoryManager_addNewSentMessage_when_zeroInitialMessages_then_messagesCountWillBeIncrementByOne() {
        let sut = makeSUT()
        let message = ChatMessageInfoModel()
        sut.addNewSendingMessage(message: message)
        XCTAssertEqual(sut.messages.count, 1)
    }

    func test_messageRepositoryManager_replaceMessageId_when_foundMatchingInternalId_then_actualIdWillBeUpdated() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let internalId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let expectedActualId = "actualMessageId"
        let sut = makeSUT(messages: initialMessages)
        sut.replaceMessageId(internalId: internalId, actualId: "actualMessageId")
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertEqual(sut.messages.last?.id, expectedActualId)
    }

    func test_messageRepositoryManager_replaceMessageId_when_notFoundMatchingInternalId_then_messagesNotChanged() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let internalId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let expectedActualId = "actualMessageId"
        let sut = makeSUT(messages: initialMessages)
        sut.replaceMessageId(internalId: internalId + "notFound", actualId: "actualMessageId")
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotEqual(sut.messages.last?.id, expectedActualId)
    }

    func test_messageRepositoryManager_addTopicUpdatedMessage_then_messagesCountWillBeIncrementByOne() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        let topic = "newTopic"
        let sut = makeSUT(messages: initialMessages)
        let threadInfo = ChatThreadInfoModel(topic: topic,
                                             receivedOn: Iso8601Date())
        sut.addTopicUpdatedMessage(chatThreadInfo: threadInfo)
        XCTAssertEqual(sut.messages.count, initialMessages.count + 1)
        XCTAssertEqual(sut.messages.last?.type, .topicUpdated)
        XCTAssertEqual(sut.messages.last?.content, topic)
    }

    func test_messageRepositoryManager_addReceivedMessage_when_zeroInitialMessages_then_messagesCountWillBeIncrementByOne() {
        let sut = makeSUT()
        let message = ChatMessageInfoModel()
        sut.addReceivedMessage(message: message)
        XCTAssertEqual(sut.messages.count, 1)
    }

    func test_messageRepositoryManager_addReceivedMessage_when_nonEmptyInitialMessages_then_messagesCountWillBeIncrementByOne() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        let sut = makeSUT(messages: initialMessages)
        let message = ChatMessageInfoModel()
        sut.addReceivedMessage(message: message)
        XCTAssertEqual(sut.messages.count, initialMessages.count + 1)
    }

    func test_messageRepositoryManager_updateMessageEdited_when_foundMatchingInternalId_then_messageEditedOnNotNil() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let internalId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let sut = makeSUT(messages: initialMessages)
        let message = ChatMessageInfoModel(id: internalId,
                                           editedOn: Iso8601Date())
        sut.updateMessageEdited(message: message)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotNil(sut.messages.last?.editedOn)
    }

    func test_messageRepositoryManager_updateMessageEdited_when_notFoundMatchingInternalId_then_messageEditedOnIsNil() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let internalId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let sut = makeSUT(messages: initialMessages)
        let message = ChatMessageInfoModel(id: internalId + "notFound",
                                           editedOn: Iso8601Date())
        sut.updateMessageEdited(message: message)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        for m in sut.messages {
            XCTAssertNil(m.editedOn)
        }
    }

    func test_messageRepositoryManager_updateMessageDeleted_when_foundMatchingInternalId_then_messageDeletedOnNotNil() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let internalId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let sut = makeSUT(messages: initialMessages)
        let message = ChatMessageInfoModel(id: internalId,
                                           deletedOn: Iso8601Date())
        sut.updateMessageDeleted(message: message)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotNil(sut.messages.last?.deletedOn)
    }

    func test_messageRepositoryManager_updateMessageDeleted_when_notFoundMatchingInternalId_then_messageDeletedOnIsNil() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let internalId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let sut = makeSUT(messages: initialMessages)
        let message = ChatMessageInfoModel(id: internalId + "notFound",
                                           deletedOn: Iso8601Date())
        sut.updateMessageDeleted(message: message)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        for m in sut.messages {
            XCTAssertNil(m.deletedOn)
        }
    }
}

extension MessageRepositoryManagerTests {
    func makeSUT(messages: [ChatMessageInfoModel] = []) -> MessageRepositoryManager {
        let sut = MessageRepositoryManager(chatCompositeEventsHandler: eventsHandler)
        sut.messages = messages
        return sut
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

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

    func test_messageRepositoryManager_addPreviousMessages_with_nonEmptyPreviousMessages_then_messagesCountWillBeMatching() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        let sut = makeSUT(messages: initialMessages)

        let previousMessages1 = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        let previousMessages2 = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        sut.addPreviousMessages(previousMessages: previousMessages1)
        XCTAssertEqual(sut.messages.count,
                       initialMessages.count +
                       previousMessages1.count)
        sut.addPreviousMessages(previousMessages: previousMessages2)
        XCTAssertEqual( sut.messages.count,
                        initialMessages.count +
                        previousMessages1.count +
                        previousMessages2.count)
    }

    func test_messageRepositoryManager_addPreviousMessages_with_previousMessagesContainExistingMessage_then_messagesCountWillBeIgnoreExistingMessages() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        let messageId1 = initialMessages[0].id
        let messageId2 = initialMessages[1].id
        let duplicateCount = 2
        let sut = makeSUT(messages: initialMessages)

        let previousMessages1 = [
            ChatMessageInfoModel(id: messageId1),
            ChatMessageInfoModel(id: messageId2),
            ChatMessageInfoModel()
        ]

        sut.addPreviousMessages(previousMessages: previousMessages1)
        XCTAssertEqual(sut.messages.count,
                       initialMessages.count +
                       previousMessages1.count -
                       duplicateCount)
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
        let message = ChatMessageInfoModel()
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
        let message = ChatMessageInfoModel()
        sut.replaceMessageId(internalId: internalId + "notFound", actualId: "actualMessageId")
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotEqual(sut.messages.last?.id, expectedActualId)
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
}

extension MessageRepositoryManagerTests {
    func makeSUT(messages: [ChatMessageInfoModel] = []) -> MessageRepositoryManager {
        let sut = MessageRepositoryManager(chatCompositeEventsHandler: eventsHandler)
        sut.messages = messages
        return sut
    }
}

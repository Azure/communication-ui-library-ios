//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import AzureCore
import XCTest
@testable import AzureCommunicationUIChat

class MessageRepositoryManagerTests: XCTestCase {
    var eventsHandler: ChatAdapter.Events!

    override func setUp() {
        super.setUp()
        eventsHandler = ChatAdapter.Events()
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

    func test_messageRepositoryManager_editMessage_when_foundMatchingMessageId_then_contentAndTimestampWillBeUpdated() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let messageId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let expectedContent = "editedContent"
        let sut = makeSUT(messages: initialMessages)
        sut.editMessage(messageId: messageId, content: expectedContent)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotNil(sut.messages.last?.editedOn)
        XCTAssertEqual(sut.messages.last?.content, expectedContent)
    }

    func test_messageRepositoryManager_deleteMessage_when_foundMatchingMessageId_then_deletedOnWillBeNotNil() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let messageId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let sut = makeSUT(messages: initialMessages)
        sut.deleteMessage(messageId: messageId)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotNil(sut.messages.last?.deletedOn)
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

    func test_messageRepositoryManager_updateEditMessageTimestamp_when_foundMatchingMessageId_then_editedOnWillBeNotNil() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let messageId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let sut = makeSUT(messages: initialMessages)
        sut.updateEditMessageTimestamp(messageId: messageId)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotNil(sut.messages.last?.editedOn)
    }

    func test_messageRepositoryManager_updateDeletedMessageTimestamp_when_foundMatchingMessageId_then_editedOnWillBeNotNil() {
        let initialMessages = [
            ChatMessageInfoModel(),
            ChatMessageInfoModel(),
            ChatMessageInfoModel()
        ]
        guard let messageId = initialMessages.last?.id else {
            XCTFail("Should have at least one message")
            return
        }
        let sut = makeSUT(messages: initialMessages)
        sut.updateDeletedMessageTimestamp(messageId: messageId)
        XCTAssertEqual(sut.messages.count, initialMessages.count)
        XCTAssertNotNil(sut.messages.last?.deletedOn)
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

    func test_messageRepositoryManager_updateMessageReadReceiptStatus_when_everyParticipantHasReadMessage_then_sendStatusWillBeUpdated() {
        let lastMessageId = "1668456344995"
        let initialMessages = [
            ChatMessageInfoModel(id: "1668436344995"),
            ChatMessageInfoModel(id: "1668446344995"),
            ChatMessageInfoModel(id: lastMessageId)
        ]

        let sut = makeSUT(messages: initialMessages)
        let readReceiptInfo = ReadReceiptInfoModel(senderIdentifier: CommunicationUserIdentifier("identifier"), chatMessageId: lastMessageId, readOn: Iso8601Date())
        guard let messageIdDouble = Double(lastMessageId) else {
            XCTFail("Message Id should be able to be converted to Double")
            return
        }
        let readReceiptMap = [
            "Participant1": Date(timeIntervalSince1970: (messageIdDouble + 300) / 1000),
            "Participant2": Date(timeIntervalSince1970: (messageIdDouble + 200) / 1000),
            "Participant3": Date(timeIntervalSince1970: (messageIdDouble + 100) / 1000)
        ]
        let participantsState = ParticipantsState(readReceiptMap: readReceiptMap)
        sut.updateMessageReadReceiptStatus(readReceiptInfo: readReceiptInfo, state: getAppState(participantsState: participantsState))

        XCTAssertNil(sut.messages.first?.sendStatus)
        XCTAssertEqual(sut.messages.last?.sendStatus, .seen)
    }

    func test_messageRepositoryManager_updateMessageReadReceiptStatus_when_someParticipantsHaveReadMessage_then_sendStatusWillNotBeUpdated() {
        let lastMessageId = "1668456344995"
        let initialMessages = [
            ChatMessageInfoModel(id: "1668436344995"),
            ChatMessageInfoModel(id: "1668446344995"),
            ChatMessageInfoModel(id: lastMessageId)
        ]

        let sut = makeSUT(messages: initialMessages)
        let readReceiptInfo = ReadReceiptInfoModel(senderIdentifier: CommunicationUserIdentifier("identifier"), chatMessageId: lastMessageId, readOn: Iso8601Date())
        guard let messageIdDouble = Double(lastMessageId) else {
            XCTFail("Message Id should be able to be converted to Double")
            return
        }
        let readReceiptMap = [
            "Participant1": Date(timeIntervalSince1970: (messageIdDouble - 300) / 1000),
            "Participant2": Date(timeIntervalSince1970: (messageIdDouble - 200) / 1000),
            "Participant3": Date(timeIntervalSince1970: (messageIdDouble) / 1000)
        ]
        let participantsState = ParticipantsState(readReceiptMap: readReceiptMap)
        sut.updateMessageReadReceiptStatus(readReceiptInfo: readReceiptInfo, state: getAppState(participantsState: participantsState))

        XCTAssertNil(sut.messages.first?.sendStatus)
        XCTAssertNil(sut.messages.last?.sendStatus)
    }

    func test_messageRepositoryManager_addLocalUserRemovedMessage_when_initialMessages_then_messagesCountWillBeIncrementByOne() {
        let sut = makeSUT()
        sut.addLocalUserRemovedMessage()
        XCTAssertEqual(sut.messages.count, 1)
    }

    func test_messageRepositoryManager_updateMessageSendStatus_when_foundMatchingMessageId_then_messageSendStatusWillBeUpdated() {
        let initialMessages = [
            ChatMessageInfoModel(id: "id1"),
            ChatMessageInfoModel(id: "id2"),
            ChatMessageInfoModel(id: "id3")
        ]

        let sut = makeSUT(messages: initialMessages)
        sut.updateMessageSendStatus(messageId: "id3", messageSendStatus: .failed)
        XCTAssertEqual(sut.messages.last?.sendStatus, .failed)
    }

    func test_messageRepositoryManager_updateMessageSendStatus_when_notFoundMatchingMessageId_then_messageDeletedOnIsNil() {
        let initialMessages = [
            ChatMessageInfoModel(id: "id1"),
            ChatMessageInfoModel(id: "id2"),
            ChatMessageInfoModel(id: "id3")
        ]

        let sut = makeSUT(messages: initialMessages)
        sut.updateMessageSendStatus(messageId: "wrongMessageId", messageSendStatus: .failed)
        XCTAssertNil(sut.messages[0].sendStatus)
        XCTAssertNil(sut.messages[1].sendStatus)
        XCTAssertNil(sut.messages[2].sendStatus)
    }
}

extension MessageRepositoryManagerTests {
    func makeSUT(messages: [ChatMessageInfoModel] = []) -> MessageRepositoryManager {
        let sut = MessageRepositoryManager(chatCompositeEventsHandler: eventsHandler)
        sut.messages = messages
        return sut
    }

    func getAppState(participantsState: ParticipantsState) -> AppState {
        return AppState(lifeCycleState: LifeCycleState(),
                        chatState: ChatState(),
                        participantsState: participantsState,
                        navigationState: NavigationState(),
                        repositoryState: RepositoryState(),
                        errorState: ErrorState())
    }
}

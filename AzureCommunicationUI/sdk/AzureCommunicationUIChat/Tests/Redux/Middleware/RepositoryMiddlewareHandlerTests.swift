//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import AzureCore
import Combine
import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class RepositoryMiddlewareHandlerTests: XCTestCase {

    var repositoryMiddlewareHandler: RepositoryMiddlewareHandler!
    var mockLogger: LoggerMocking!
    var mockMessageRepositoryManager: MessageRepositoryManagerMocking!

    override func setUp() {
        super.setUp()
        mockMessageRepositoryManager = MessageRepositoryManagerMocking()
        mockLogger = LoggerMocking()
        repositoryMiddlewareHandler = RepositoryMiddlewareHandler(
            messageRepository: mockMessageRepositoryManager,
            logger: mockLogger)
    }

    override func tearDown() {
        super.tearDown()
        mockMessageRepositoryManager = nil
        mockLogger = nil
        repositoryMiddlewareHandler = nil
    }

    func test_repositoryMiddlewareHandler_loadInitialMessages_then_addInitialMessagesCalled() async {
        await repositoryMiddlewareHandler.loadInitialMessages(
            messages: [],
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.addInitialMessagesCalled)
    }

    func test_repositoryMiddlewareHandler_addPreviousMessages_then_addPreviousMessagesCalled() async {
        await repositoryMiddlewareHandler.addPreviousMessages(
            messages: [ChatMessageInfoModel()],
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.addPreviousMessagesCalled)
    }

    func test_repositoryMiddlewareHandler_addNewSentMessage_then_addNewSentMessageCalled() async {
        await repositoryMiddlewareHandler.addNewSentMessage(
            internalId: "internalId",
            content: "content",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.addNewSentMessageCalled)
    }

    func test_repositoryMiddlewareHandler_updateNewEditedMessage_then_editMessageCalled() async {
        await repositoryMiddlewareHandler.updateNewEditedMessage(
            messageId: "messageId",
            content: "content",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.editMessageCalled)
    }

    func test_repositoryMiddlewareHandler_updateNewDeletedMessage_then_deleteMessageCalled() async {
        await repositoryMiddlewareHandler.updateNewDeletedMessage(
            messageId: "messageId",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.deleteMessageCalled)
    }

    func test_repositoryMiddlewareHandler_updateSentMessageId_then_replaceMessageIdCalled() async {
        await repositoryMiddlewareHandler.updateSentMessageId(
            internalId: "internalId",
            actualId: "actualId",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.replaceMessageIdCalled)
    }

    func test_repositoryMiddlewareHandler_updateEditedMessageTimestamp_then_updateEditMessageTimestampCalled() async {
        await repositoryMiddlewareHandler.updateEditedMessageTimestamp(
            messageId: "messageId",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.updateEditMessageTimestampCalled)
    }

    func test_repositoryMiddlewareHandler_updateDeletedMessageTimestamp_then_updateDeletedMessageTimestampCalled() async {
        await repositoryMiddlewareHandler.updateDeletedMessageTimestamp(
            messageId: "messageId",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.updateDeletedMessageTimestampCalled)
    }

    func test_repositoryMiddlewareHandler_addTopicUpdatedMessage_then_addTopicUpdatedMessageCalled() async {
        let threadInfo = ChatThreadInfoModel(topic: "topic", receivedOn: Iso8601Date())
        await repositoryMiddlewareHandler.addTopicUpdatedMessage(
            threadInfo: threadInfo,
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.addTopicUpdatedMessageCalled)
    }

    func test_repositoryMiddlewareHandler_participantAddedMessage_then_participantAddedMessageCalled() async {
        let addParticipant = [ParticipantInfoModel(identifier: UnknownIdentifier("SomeUnknownIdentifier"),
                                                   displayName: "MockBot")]
        await repositoryMiddlewareHandler.participantAddedMessage(participants: addParticipant,
                                                                  dispatch: getEmptyDispatch()).value
        let lastMessage = mockMessageRepositoryManager.messages.last
        XCTAssertTrue(mockMessageRepositoryManager.addParticipantAddedMessageCalled)
        XCTAssertEqual(lastMessage?.type, .participantsAdded)
        XCTAssertEqual(lastMessage?.participants, addParticipant)
    }

    func test_repositoryMiddlewareHandler_participantRemovedMessage_then_participantRemovedMessageCalled() async {
        let removedParticipant = [ParticipantInfoModel(identifier: UnknownIdentifier("SomeUnknownIdentifier"),
                                                       displayName: "MockBot")]
        let localParticipant = ParticipantInfoModel(identifier: UnknownIdentifier("LocalUserIdentifier"),
                                                       displayName: "LocalUser")
        await repositoryMiddlewareHandler.participantRemovedMessage(participants: removedParticipant,
                                                                    dispatch: getEmptyDispatch()).value
        let lastMessage = mockMessageRepositoryManager.messages.last
        XCTAssertTrue(mockMessageRepositoryManager.addParticipantRemovedMessageCalled)
        XCTAssertEqual(lastMessage?.type, .participantsRemoved)
        XCTAssertEqual(lastMessage?.participants, removedParticipant)
    }

    func test_repositoryMiddlewareHandler_localParticipantRemoved_then_chatMessageLocalUserRemovedCalled() async {
        let removedParticipant = ParticipantInfoModel(identifier: UnknownIdentifier("SomeUnknownIdentifier"),
                                                       displayName: "MockBot")
        await repositoryMiddlewareHandler.participantRemovedMessage(participants: [removedParticipant],
                                                                    dispatch: getEmptyDispatch()).value
        XCTAssertFalse(mockMessageRepositoryManager.addlocalUserRemovedMessageCalled)
    }

    func test_repositoryMiddlewareHandler_localParticipantRemoved_then_chatMessageLocalUserRemovedNotCalled() async {
        let removedParticipant = ParticipantInfoModel(identifier: UnknownIdentifier("SomeUnknownIdentifier"),
                                                       displayName: "MockBot")
        await repositoryMiddlewareHandler.participantRemovedMessage(participants: [removedParticipant],
                                                                    dispatch: getEmptyDispatch()).value
        XCTAssertFalse(mockMessageRepositoryManager.addlocalUserRemovedMessageCalled)
    }

    func test_repositoryMiddlewareHandler_addReceivedMessage_then_addReceivedMessageCalled() async {
        let message = ChatMessageInfoModel()
        await repositoryMiddlewareHandler.addReceivedMessage(
            message: message,
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.addReceivedMessageCalled)
    }

    func test_repositoryMiddlewareHandler_updateReceivedEditedMessage_then_updateMessageEditedCalled() async {
        let message = ChatMessageInfoModel()
        await repositoryMiddlewareHandler.updateReceivedEditedMessage(
            message: message,
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.updateMessageEditedCalled)
    }

    func test_repositoryMiddlewareHandler_updateReceivedDeletedMessage_then_updateMessageDeletedCalled() async {
        let message = ChatMessageInfoModel()
        await repositoryMiddlewareHandler.updateReceivedDeletedMessage(
            message: message,
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.updateMessageDeletedCalled)
    }

    func test_repositoryMiddlewareHandler_addLocalUserRemovedMessage_then_addLocalUserRemovedMessageCalled() async {
        let message = ChatMessageInfoModel()
        await repositoryMiddlewareHandler.addLocalUserRemovedMessage(state: getEmptyState(),
                                                                     dispatch: getEmptyDispatch()) .value
        XCTAssertTrue(mockMessageRepositoryManager.addlocalUserRemovedMessageCalled)
    }
}

extension RepositoryMiddlewareHandlerTests {

    private func getEmptyState() -> AppState {
        let localUser = ParticipantInfoModel(
            identifier: CommunicationUserIdentifier("identifier"),
            displayName: "displayName")
        let chatState = ChatState(localUser: localUser)
        return AppState(chatState: chatState)
    }

    private func getEmptyDispatch() -> ActionDispatch {
        return { _ in }
    }

    private func getError(code: Int = 100) -> Error {
        return NSError(domain: "", code: code, userInfo: [
            NSLocalizedDescriptionKey: "Error"
        ])
    }

}

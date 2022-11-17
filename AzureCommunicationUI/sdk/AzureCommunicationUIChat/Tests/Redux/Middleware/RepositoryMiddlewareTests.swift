//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Combine
import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class RepositoryMiddlewareTests: XCTestCase {

    var mockRepositoryHandler: RepositoryHandlerMocking!
    var mockMiddleware: Middleware<AppState>!

    override func setUp() {
        super.setUp()
        mockRepositoryHandler = RepositoryHandlerMocking()
        mockMiddleware = .liveRepositoryMiddleware(
            repositoryMiddlewareHandler: mockRepositoryHandler)
    }

    override func tearDown() {
        super.tearDown()
        mockRepositoryHandler = nil
        mockMiddleware = nil
    }

    func test_repositoryMiddleware_apply_when_fetchInitialMessagesSuccessRepositoryAction_then_handlerAddTopicUpdatedMessageCalledBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "addTopicUpdatedMessageCalled")
        mockRepositoryHandler.addTopicUpdatedMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        let threadInfo = ChatThreadInfoModel(topic: "newTopic", receivedOn: Iso8601Date())
        middlewareDispatch(getEmptyDispatch())(.chatAction(.chatTopicUpdated(threadInfo: threadInfo)))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_fetchInitialMessagesSuccessRepositoryAction_then_handlerLoadInitialMessagesCalledBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "loadInitialMessagesCalled")
        mockRepositoryHandler.loadInitialMessagesCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        let messages: [ChatMessageInfoModel] = []
        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.fetchInitialMessagesSuccess(messages: messages)))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_fetchPreviousMessagesSuccessRepositoryAction_then_handlerAddPreviousCalledMessagesCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "loadInitialMessagesCalled")
        mockRepositoryHandler.addPreviousMessagesCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        let messages: [ChatMessageInfoModel] = []
        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.fetchPreviousMessagesSuccess(messages: messages)))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_sendMessageTriggeredRepositoryAction_then_handlerLoadInitialMessagesCalledBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "addNewSentMessageCalled")
        mockRepositoryHandler.addNewSentMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.sendMessageTriggered(
            internalId: "internalId",
            content: "content")))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_editMessageTriggeredRepositoryAction_then_handlerUpdateNewEditedMessageBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "updateNewEditedMessageCalled")
        mockRepositoryHandler.updateNewEditedMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.editMessageTriggered(
            messageId: "messageId",
            content: "content",
            prevContent: "prevContent")))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_deleteMessageTriggeredRepositoryAction_then_handlerUpdateNewDeletedMessageBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "updateNewDeletedMessageCalled")
        mockRepositoryHandler.updateNewDeletedMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.deleteMessageTriggered(
            messageId: "messageId")))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_sendMessageSuccessRepositoryAction_then_handlerLoadInitialMessagesCalledBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "updateSentMessageIdCalled")
        mockRepositoryHandler.updateSentMessageIdCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.sendMessageSuccess(
            internalId: "internalId",
            actualId: "actualId")))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_editMessageTriggeredRepositoryAction_then_handlerUpdateEditedMessageTimestampBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "updateEditedMessageTimestampCalled")
        mockRepositoryHandler.updateEditedMessageTimestampCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.editMessageSuccess(
            messageId: "messageId")))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_editMessageTriggeredRepositoryAction_then_handlerUpdateDeletedMessageTimestampBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "updateDeletedMessageTimestampCalled")
        mockRepositoryHandler.updateDeletedMessageTimestampCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.deleteMessageSuccess(
            messageId: "messageId")))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_chatMessageReceivedRepositoryAction_then_handlerAddReceivedMessageBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "addReceivedMessageCalled")
        mockRepositoryHandler.addReceivedMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        let message = ChatMessageInfoModel()
        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.chatMessageReceived(message: message)))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_chatMessageEditedReceivedRepositoryAction_then_handlerUpdateReceivedEditedMessageBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "updateReceivedEditedMessageCalled")
        mockRepositoryHandler.updateReceivedEditedMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        let message = ChatMessageInfoModel()
        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.chatMessageEditedReceived(message: message)))
        wait(for: [expectation], timeout: 1)
    }

    func test_repositoryMiddleware_apply_when_chatMessageDeletedReceivedRepositoryAction_then_handlerUpdateReceivedDeletedMessageCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "updateReceivedDeletedMessageCalled")
        mockRepositoryHandler.updateReceivedDeletedMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        let message = ChatMessageInfoModel()
        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.chatMessageDeletedReceived(message: message)))
        wait(for: [expectation], timeout: 1)
    }
}

extension RepositoryMiddlewareTests {

    private func getEmptyState() -> AppState {
        return AppState()
    }
    private func getEmptyDispatch() -> ActionDispatch {
        return { _ in }
    }

    private func getEmptyChatMiddlewareFunction() -> (@escaping ActionDispatch) -> ActionDispatch {
        return mockMiddleware.apply(getEmptyDispatch(), getEmptyState)
    }

    private func getAssertSameActionDispatch(action: Action, expectation: XCTestExpectation) -> ActionDispatch {
        return { nextAction in
            XCTAssertTrue(type(of: action) == type(of: nextAction))
            expectation.fulfill()
        }
    }
}

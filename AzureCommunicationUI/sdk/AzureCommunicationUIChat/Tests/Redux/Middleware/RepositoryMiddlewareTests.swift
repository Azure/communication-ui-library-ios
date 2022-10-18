//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
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

    func test_repositoryMiddleware_apply_when_chatMessageReceivedRepositoryAction_then_handleraddReceivedMessageBeingCalled() {

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

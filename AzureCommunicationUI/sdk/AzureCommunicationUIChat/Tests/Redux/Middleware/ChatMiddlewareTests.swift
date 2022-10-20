//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
@testable import AzureCommunicationUIChat

class ChatMiddlewareTests: XCTestCase {

    var mockChatActionHandler: ChatActionHandlerMocking!
    var mockChatServiceEventHandler: ChatServiceEventHandlerMocking!
    var mockMiddleware: Middleware<AppState>!

    override func setUp() {
        super.setUp()
        mockChatActionHandler = ChatActionHandlerMocking()
        mockChatServiceEventHandler = ChatServiceEventHandlerMocking()
        mockMiddleware = .liveChatMiddleware(
            chatActionHandler: mockChatActionHandler,
            chatServiceEventHandler: mockChatServiceEventHandler)
    }

    override func tearDown() {
        super.tearDown()
        mockChatActionHandler = nil
        mockChatServiceEventHandler = nil
        mockMiddleware = nil
    }

    func test_chatMiddleware_apply_when_initializeChatTriggeredChatAction_then_handlerInitializeBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "initializeWasCalled")
        mockChatActionHandler.initializeCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.chatAction(.initializeChatTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_chatMiddleware_apply_when_fetchInitialMessagesTriggeredRepositoryAction_then_handlerGetInitialMessagesBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "getInitialMessagesWasCalled")
        mockChatActionHandler.getInitialMessagesCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.fetchInitialMessagesTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_chatMiddleware_apply_when_sendMessageTriggeredRepositoryAction_then_handlerSendMessageCalledBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "sendMessageCalled")
        mockChatActionHandler.sendMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.sendMessageTriggered(internalId: "internalId", content: "content")))
        wait(for: [expectation], timeout: 1)
    }

    func test_chatMiddleware_apply_when_sendTypingIndicatorTriggered_then_handlerSendTypingIndicatorCalled() {
        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "sendTypingIndicatorCalled")
        mockChatActionHandler.sendTypingIndicatorCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }
        middlewareDispatch(getEmptyDispatch())(.chatAction(.sendTypingIndicatorTriggered))
        wait(for: [expectation], timeout: 1)
    }
}

extension ChatMiddlewareTests {

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

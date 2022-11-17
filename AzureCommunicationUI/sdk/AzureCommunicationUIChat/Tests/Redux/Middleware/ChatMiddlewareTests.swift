//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@testable import AzureCommunicationUIChat
import AzureCommunicationCommon
import AzureCore
import Combine
import Foundation
import XCTest

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

    func test_chatMiddleware_apply_when_chatThreadDeletedChatAction_then_handlerNnChatThreadDeletedCalledCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "onChatThreadDeletedCalled")
        mockChatActionHandler.onChatThreadDeletedCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.chatAction(.chatThreadDeleted))
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

    func test_chatMiddleware_apply_when_fetchInitialMessagesTriggeredRepositoryAction_then_handlerGetListOfParticipantsBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "getListOfParticipantsWasCalled")
        mockChatActionHandler.getListOfParticipantsCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.fetchInitialMessagesTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_chatMiddleware_apply_when_sendMessageTriggeredRepositoryAction_then_handlerGetPreviousMessagesBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "getPreviousMessagesWasCalled")
        mockChatActionHandler.getPreviousMessagesCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.fetchPreviousMessagesTriggered))
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

    func test_chatMiddleware_apply_when_editMessageTriggeredRepositoryAction_then_handlerEditMessageCalledBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "editMessageCalled")
        mockChatActionHandler.editMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.editMessageTriggered(messageId: "messageId", content: "content", prevContent: "prevContent")))
        wait(for: [expectation], timeout: 1)
    }

    func test_chatMiddleware_apply_when_deleteMessageTriggeredRepositoryAction_then_handlerEditMessageCalledBeingCalled() {

        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "deleteMessageCalled")
        mockChatActionHandler.deleteMessageCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.repositoryAction(.deleteMessageTriggered(messageId: "messageId")))
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

    func test_chatMiddleware_apply_when_recieveTypingIndicatorTriggered_then_handlerSetTypingIndicatorTimeoutCalled() {
        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "setTypingIndicatorTimeoutCalled")
        mockChatActionHandler.setTypingIndicatorTimeoutCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }
        let model = UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(""),
                                            timestamp: Iso8601Date())!
        middlewareDispatch(getEmptyDispatch())(.participantsAction(.typingIndicatorReceived(participant: model)))
        wait(for: [expectation], timeout: 1)
    }

    func test_chatMiddleware_apply_when_sendReadReceiptTriggered_then_handlerSendReadReceiptCalledBeingCalled() {
        let middlewareDispatch = getEmptyChatMiddlewareFunction()
        let expectation = expectation(description: "sendReadReceiptCalled")
        mockChatActionHandler.sendReadReceiptCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.participantsAction(.sendReadReceiptTriggered(messageId: "messageId")))
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

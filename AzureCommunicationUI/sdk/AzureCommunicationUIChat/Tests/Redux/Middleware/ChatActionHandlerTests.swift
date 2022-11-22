//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import AzureCommunicationCommon
import XCTest
import Combine
@testable import AzureCommunicationUIChat

class ChatActionHandlerTests: XCTestCase {

    var mockLogger: LoggerMocking!
    var mockChatService: ChatServiceMocking!
    var mockChatServiceEventHandler: ChatServiceEventHandlerMocking!

    override func setUp() {
        super.setUp()
        mockChatService = ChatServiceMocking()
        mockChatServiceEventHandler = ChatServiceEventHandlerMocking()
        mockLogger = LoggerMocking()
    }

    override func tearDown() {
        super.tearDown()
        mockChatService = nil
        mockChatServiceEventHandler = nil
        mockLogger = nil
    }

    func test_chatActionHandler_initialize_then_initializeCalled() async {
        let sut = makeSUT()
        await sut.initialize(
            state: getEmptyState(),
            dispatch: getEmptyDispatch(),
            serviceListener: mockChatServiceEventHandler).value
        XCTAssertTrue(mockChatService.initializeCalled)
    }

    func test_chatActionHandler_getInitialMessages_then_getInitialMessagesCalled() async {
        let sut = makeSUT()
        await sut.getInitialMessages(
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.getInitialMessagesCalled)
    }

    func test_chatActionHandler_getListOfParticipants_then_getListOfParticipantsCalled() async {
        let sut = makeSUT()
        await sut.getListOfParticipants(
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.getListOfParticipantsCalled)
    }

    func test_chatActionHandler_getPreviousMessages_when_nonEmptyPreviousMessages_then_getPreviousMessagesCalled() async {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let previousMessages = [ChatMessageInfoModel()]
        func dispatch(action: Action) { XCTAssertTrue(mockChatService.getPreviousMessagesCalled)
            XCTAssertTrue(action == Action.repositoryAction(.fetchPreviousMessagesSuccess(messages: previousMessages)))
            expectation.fulfill()
        }
        let sut = makeSUT(previousMessages: previousMessages)
        await sut.getPreviousMessages(
            state: getEmptyState(),
            dispatch: dispatch).value

        wait(for: [expectation], timeout: 1)
    }

    func test_chatActionHandler_getPreviousMessages_when_emptyPreviousMessages_then_getPreviousMessagesCalled() async {
        let expectation = XCTestExpectation(description: "Not dispatch the new action")
        expectation.isInverted = true
        func dispatch(action: Action) {
            XCTFail("Should not call this")
        }
        let sut = makeSUT(previousMessages: [])
        await sut.getPreviousMessages(
            state: getEmptyState(),
            dispatch: dispatch).value
        XCTAssertTrue(mockChatService.getPreviousMessagesCalled)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatActionHandler_sendMessage_then_sendMessageCalled() async {
        let sut = makeSUT()
        await sut.sendMessage(
            internalId: "internalId",
            content: "content",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.sendMessageCalled)
    }

    func test_chatActionHandler_editMessage_then_editMessageCalled() async {
        let sut = makeSUT()
        await sut.editMessage(
            messageId: "messageId",
            content: "content",
            prevContent: "prevContent",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.editMessageCalled)
    }

    func test_chatActionHandler_deleteMessage_then_deleteMessageCalled() async {
        let sut = makeSUT()
        await sut.deleteMessage(
            messageId: "messageId",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.deleteMessageCalled)
    }

    func test_chatActionHandler_sendTypingIndicator_then_sendTypingIndicatorCalled() async {
        let sut = makeSUT()
        await sut.sendTypingIndicator(state: getEmptyState(),
                                      dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockChatService.sendTypingIndicatorCalled)
    }

    func test_chatActionHandler_sendTypingIndicator_then_sendTypingIndicatorDispatched() async {
        let expectation = XCTestExpectation(description: "Dispatch Send Typing Indicator Success")
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.chatAction(.sendTypingIndicatorSuccess))
            expectation.fulfill()
        }
        let sut = makeSUT()
        await sut.sendTypingIndicator(state: getEmptyState(),
                                      dispatch: dispatch).value
        wait(for: [expectation], timeout: 1)
    }

    func test_chatActionHandler_sendReadReceipt_then_sendReadReceiptCalled() async {
        let sut = makeSUT()
        await sut.sendReadReceipt(
            messageId: "messageId",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.sendReadReceiptCalled)
    }

    func test_chatActionHandler_recieveTypingIndicator_then_dispatchClearIdleTypingParticipantsAction() async {
        let expectation = XCTestExpectation(description: "Dispatch Clear Idle Typing Participants Success")
        let sut = makeSUT()
        func dispatch(action: Action) {
            switch action {
            case .participantsAction(.clearIdleTypingParticipants):
                expectation.fulfill()
            default:
                XCTFail("Unknown Action Dispatched")
            }
        }
        UserEventTimestampModel.typingParticipantTimeout = 0
        sut.setTypingParticipantTimer(getEmptyState, dispatch)
        wait(for: [expectation], timeout: 1)
    }
}

extension ChatActionHandlerTests {

    func makeSUT(initialMessages: [ChatMessageInfoModel]? = nil,
                 previousMessages: [ChatMessageInfoModel]? = nil) -> ChatActionHandler {
        if let initialMsg = initialMessages {
            mockChatService.initialMessages = initialMsg
        }
        if let previousMsg = previousMessages {
            mockChatService.previousMessages = previousMsg
        }

        return ChatActionHandler(
            chatService: mockChatService,
            logger: mockLogger,
            connectEventHandler: nil)
    }

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

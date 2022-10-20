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

    func test_chatActionHandler_onChatThreadDeleted_then_dispatchFatalErrorAction() async {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedError = ChatCompositeInternalError.chatEvicted
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: expectedError, error: nil)))
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalError, err)):
                XCTAssertEqual(internalError, expectedError)
                XCTAssertNil(err)
                XCTAssertTrue(internalError.isFatalError())
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        let sut = makeSUT()
        await sut.onChatThreadDeleted(dispatch: dispatch).value
        wait(for: [expectation], timeout: 1)
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

    func test_chatActionHandler_sendMessage_then_getInitialMessagesCalled() async {
        let sut = makeSUT()
        await sut.sendMessage(
            internalId: "internalId",
            content: "content",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.sendMessageCalled)
    }
}

extension ChatActionHandlerTests {

    func makeSUT() -> ChatActionHandler {
        return ChatActionHandler(
            chatService: mockChatService,
            logger: mockLogger)
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

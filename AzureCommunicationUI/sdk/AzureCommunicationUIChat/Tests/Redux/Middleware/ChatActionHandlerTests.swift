//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

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
}

extension ChatActionHandlerTests {

    func makeSUT() -> ChatActionHandler {
        return ChatActionHandler(
            chatService: mockChatService,
            logger: mockLogger)
    }

    private func getEmptyState() -> AppState {
        return AppState()
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

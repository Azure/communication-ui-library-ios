//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
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
        await repositoryMiddlewareHandler.loadInitialMessages(messages: []).value
        XCTAssertTrue(mockMessageRepositoryManager.addInitialMessagesCalled)
    }

    func test_repositoryMiddlewareHandler_addReceivedMessage_then_addReceivedMessageCalled() async {
        let message = ChatMessageInfoModel()
        await repositoryMiddlewareHandler.addReceivedMessage(message: message).value
        XCTAssertTrue(mockMessageRepositoryManager.addReceivedMessageCalled)
    }
}

extension RepositoryMiddlewareHandlerTests {

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

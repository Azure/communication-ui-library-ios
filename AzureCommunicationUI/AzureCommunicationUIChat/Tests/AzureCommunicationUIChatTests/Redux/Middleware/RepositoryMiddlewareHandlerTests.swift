//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
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

    func test_repositoryMiddlewareHandler_addNewSentMessage_then_addNewSentMessageCalled() async {
        await repositoryMiddlewareHandler.addNewSentMessage(
            internalId: "internalId",
            content: "content",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.addNewSentMessageCalled)
    }

    func test_repositoryMiddlewareHandler_updateSentMessageId_then_replaceMessageIdCalled() async {
        await repositoryMiddlewareHandler.updateSentMessageId(
            internalId: "internalId",
            actualId: "actualId",
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.replaceMessageIdCalled)
    }

    func test_repositoryMiddlewareHandler_addReceivedMessage_then_addReceivedMessageCalled() async {
        let message = ChatMessageInfoModel()
        await repositoryMiddlewareHandler.addReceivedMessage(
            message: message,
            state: getEmptyState(),
            dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockMessageRepositoryManager.addReceivedMessageCalled)
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

    private func getEmptyDispatch() -> ChatActionDispatch {
        return { _ in }
    }

    private func getError(code: Int = 100) -> Error {
        return NSError(domain: "", code: code, userInfo: [
            NSLocalizedDescriptionKey: "Error"
        ])
    }

}

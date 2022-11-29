//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCommunicationCommon
import Foundation
import XCTest
import Combine
@testable import AzureCommunicationUIChat

class ChatSDKEventsHandlerTests: XCTestCase {

    var logger: LoggerMocking!
    var cancellable: CancelBag!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        logger = LoggerMocking()
    }

    override func tearDown() {
        super.tearDown()
        cancellable = nil
        logger = nil
    }

    func test_chatSDKEventsHandler_handle_shouldReceiveRealtimeNotificationConnected() {
        let expectation = expectation(description: "RealtimeNotificationConnected")
        let event = TrouterEvent.realTimeNotificationConnected
        let expectedEventType = ChatEventType.realTimeNotificationConnected

        let chatEventSubject = PassthroughSubject<ChatEventModel, Never>()
        let sut = makeSUT(chatEventSubject: chatEventSubject)
        chatEventSubject.sink { chatEvent in
            let eventType = chatEvent.eventType
            let infoModel = chatEvent.infoModel
            switch (eventType, infoModel) {
            case (expectedEventType, _):
                expectation.fulfill()
            default:
                XCTFail("Should not reach default case")
            }
        }.store(in: cancellable)

        sut.handle(response: event)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatSDKEventsHandler_handle_shouldReceiveRealTimeNotificationDisconnected() {
        let expectation = expectation(description: "RealTimeNotificationDisconnected")
        let event = TrouterEvent.realTimeNotificationDisconnected
        let expectedEventType = ChatEventType.realTimeNotificationDisconnected

        let chatEventSubject = PassthroughSubject<ChatEventModel, Never>()
        let sut = makeSUT(chatEventSubject: chatEventSubject)
        chatEventSubject.sink { chatEvent in
            let eventType = chatEvent.eventType
            let infoModel = chatEvent.infoModel
            switch (eventType, infoModel) {
            case (expectedEventType, _):
                expectation.fulfill()
            default:
                XCTFail("Should not reach default case")
            }
        }.store(in: cancellable)

        sut.handle(response: event)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatSDKEventsHandler_isChatClientEvent_when_threadIdIsNil_shouldReturnTrue() {
        let threadId = "threadId"
        let eventModel = ChatEventModel(eventType: .realTimeNotificationConnected)
        let chatEventSubject = PassthroughSubject<ChatEventModel, Never>()
        let sut = makeSUT(threadId: threadId,
                          chatEventSubject: chatEventSubject)
        let result = sut.isChatClientEvent(eventModel)

        XCTAssertTrue(result)
    }

    func test_chatSDKEventsHandler_isChatClientEvent_when_threadIdIsNotNil_shouldReturnFalse() {
        let threadId = "threadId"
        let eventModel = ChatEventModel(eventType: .chatMessageReceived, threadId: threadId)
        let chatEventSubject = PassthroughSubject<ChatEventModel, Never>()
        let sut = makeSUT(threadId: threadId,
                          chatEventSubject: chatEventSubject)
        let result = sut.isChatClientEvent(eventModel)

        XCTAssertFalse(result)
    }

    func test_chatSDKEventsHandler_isLocalChatThread_when_threadIdIsNil_shouldReturnFalse() {
        let threadId = "threadId"
        let eventModel = ChatEventModel(eventType: .realTimeNotificationConnected)
        let chatEventSubject = PassthroughSubject<ChatEventModel, Never>()
        let sut = makeSUT(threadId: threadId,
                          chatEventSubject: chatEventSubject)
        let result = sut.isLocalChatThread(eventModel)

        XCTAssertFalse(result)
    }

    func test_chatSDKEventsHandler_isLocalChatThread_when_threadIdIsNotNil_shouldReturnTrue() {
        let threadId = "threadId"
        let eventModel = ChatEventModel(eventType: .chatMessageReceived, threadId: threadId)
        let chatEventSubject = PassthroughSubject<ChatEventModel, Never>()
        let sut = makeSUT(threadId: threadId,
                          chatEventSubject: chatEventSubject)
        let result = sut.isLocalChatThread(eventModel)

        XCTAssertTrue(result)
    }
}

extension ChatSDKEventsHandlerTests {
    func makeSUT(threadId: String = "threadId",
                 identifier: CommunicationIdentifier = CommunicationUserIdentifier("userId"),
                 chatEventSubject: PassthroughSubject<ChatEventModel, Never>? = nil) -> ChatSDKEventsHandler {
        let sut = ChatSDKEventsHandler(logger: logger,
                                    threadId: threadId,
                                    localUserId: identifier)
        if let subject = chatEventSubject {
            sut.chatEventSubject = subject
        }
        return sut
    }
}

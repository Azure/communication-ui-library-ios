//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
@testable import AzureCommunicationUIChat

class ParticipantsMiddlewareTests: XCTestCase {

    var mockParticipantsActionHandler: ParticipantsActionHandlerMocking!
    var mockMiddleware: Middleware<AppState>!

    override func setUp() {
        super.setUp()
        mockParticipantsActionHandler = ParticipantsActionHandlerMocking()
        mockMiddleware = .liveParticipantsMiddleware(
            participantsActionHandler: mockParticipantsActionHandler)
    }

    override func tearDown() {
        super.tearDown()
        mockParticipantsActionHandler = nil
        mockMiddleware = nil
    }

    func test_participantsMiddleware_apply_when_sendReadReceiptTriggeredParticipantsAction_then_handlerSendReadReceiptCalledBeingCalled() {

        let middlewareDispatch = getEmptyParticipantsMiddlewareFunction()
        let expectation = expectation(description: "sendReadReceiptCalled")
        mockParticipantsActionHandler.sendReadReceiptCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.participantsAction(.sendReadReceiptTriggered(messageId: "messageId")))
        wait(for: [expectation], timeout: 1)
    }
}

extension ParticipantsMiddlewareTests {

    private func getEmptyState() -> AppState {
        return AppState()
    }
    private func getEmptyDispatch() -> ActionDispatch {
        return { _ in }
    }

    private func getEmptyParticipantsMiddlewareFunction() -> (@escaping ActionDispatch) -> ActionDispatch {
        return mockMiddleware.apply(getEmptyDispatch(), getEmptyState)
    }
}

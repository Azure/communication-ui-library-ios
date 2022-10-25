//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import AzureCommunicationCommon
import XCTest
import Combine
@testable import AzureCommunicationUIChat

class ParticipantsActionHandlerTests: XCTestCase {

    var mockLogger: LoggerMocking!
    var mockChatService: ChatServiceMocking!

    override func setUp() {
        super.setUp()
        mockChatService = ChatServiceMocking()
        mockLogger = LoggerMocking()
    }

    override func tearDown() {
        super.tearDown()
        mockChatService = nil
        mockLogger = nil
    }

    func test_participantsActionHandler_sendReadReceipt_then_sendReadReceiptCalled() async {
        let sut = makeSUT()
        await sut.sendReadReceipt(
            messageId: "messageId",
            dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockChatService.sendReadReceiptCalled)
    }
}

extension ParticipantsActionHandlerTests {

    func makeSUT(initialMessages: [ChatMessageInfoModel]? = nil,
                 previousMessages: [ChatMessageInfoModel]? = nil) -> ParticipantsActionHandler {
        if let initialMsg = initialMessages {
            mockChatService.initialMessages = initialMsg
        }
        if let previousMsg = previousMessages {
            mockChatService.previousMessages = previousMsg
        }

        return ParticipantsActionHandler(
            chatService: mockChatService,
            logger: mockLogger)
    }

    private func getEmptyDispatch() -> ActionDispatch {
        return { _ in }
    }

}

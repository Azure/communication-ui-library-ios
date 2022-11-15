//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import Combine
@testable import AzureCommunicationUIChat

class ChatServiceTests: XCTestCase {

    var logger: LoggerMocking!
    var chatSDKWrapper: ChatSDKWrapperMocking!
    var chatService: ChatService!
    var cancellable: CancelBag!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        logger = LoggerMocking()
        chatSDKWrapper = ChatSDKWrapperMocking()
        chatService = ChatService(logger: logger,
                                  chatSDKWrapper: chatSDKWrapper)
    }

    override func tearDown() {
        super.tearDown()
        cancellable = nil
        logger = nil
        chatSDKWrapper = nil
        chatService = nil
    }

    func test_chatService_initialize_shouldCallchatSDKWrapperinitialize() async throws {
        try await chatService.initialize()

        XCTAssertTrue(chatSDKWrapper.initializeCalled)
    }

    func test_chatService_getInitialMessages_shouldCallchatSDKWrapperGetInitialMessages() async throws {
        _ = try await chatService.getInitialMessages()

        XCTAssertTrue(chatSDKWrapper.getInitialMessagesCalled)
    }

    func test_chatService_getListOfParticipants_shouldCallchatSDKWrapperGetListOfParticipantsCalled() async throws {
        _ = try await chatService.getListOfParticipants()

        XCTAssertTrue(chatSDKWrapper.getListOfParticipantsCalled)
    }

    func test_chatService_getPreviousMessages_shouldCallchatSDKWrapperGetPreviousMessages() async throws {
        _ = try await chatService.getPreviousMessages()

        XCTAssertTrue(chatSDKWrapper.getPreviousMessagesCalled)
    }

    func test_chatService_sendMessage_shouldCallchatSDKWrappersendMessage() async throws {
        _ = try await chatService.sendMessage(content: "content", senderDisplayName: "displayName")

        XCTAssertTrue(chatSDKWrapper.sendMessageCalled)
    }

    func test_chatService_sendReadReceipt_shouldCallchatSDKWrappersendReadReceipt() async throws {
        _ = try await chatService.sendReadReceipt(messageId: "messageId")
        XCTAssertTrue(chatSDKWrapper.sendReadReceiptCalled)
    }

    func test_chatService_sendTypingIndicator_shouldCallchatSDKWrapperSendTypingIndicator() async throws {
        _ = try await chatService.sendTypingIndicator()
        XCTAssertTrue(chatSDKWrapper.sendTypingIndicatorCalled)
    }
}

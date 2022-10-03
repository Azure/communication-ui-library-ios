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
        _ = try await chatService.initalize()

        XCTAssertTrue(chatSDKWrapper.initializeCalled)
    }

    func test_chatService_getInitialMessages_shouldCallchatSDKWrapperGetInitialMessages() async throws {
        _ = try await chatService.getInitialMessages()

        XCTAssertTrue(chatSDKWrapper.getInitialMessagesCalled)
    }
}

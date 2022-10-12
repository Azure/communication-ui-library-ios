//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import AzureCore
import Combine
import Foundation
import XCTest

@testable import AzureCommunicationUIChat

class ChatServiceEventHandlerTests: XCTestCase {

    var chatServiceEventHandler: ChatServiceEventHandler!
    var mockLogger: LoggerMocking!
    var mockChatService: ChatServiceMocking!

    override func setUp() {
        super.setUp()
        mockChatService = ChatServiceMocking()
        mockLogger = LoggerMocking()
        chatServiceEventHandler = ChatServiceEventHandler(chatService: mockChatService, logger: mockLogger)
    }

    override func tearDown() {
        super.tearDown()
        mockChatService = nil
        mockLogger = nil
        chatServiceEventHandler = nil
    }

    func test_chatServiceEventHandler_subscription_when_receiveChatMessageReceivedEvent_then_dispatchChatMessageReceivedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        func dispatch(action: Action) {
            switch action {
            case .repositoryAction(.chatMessageReceived(_)):
                expectation.fulfill()
            default:
                XCTExpectFailure("Working on a fix for this problem.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatMessageReceivedEvent = ChatEventModel(
            eventType: .chatMessageReceived,
            infoModel: ChatMessageInfoModel())
        mockChatService.chatEventSubject.send(chatMessageReceivedEvent)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveTypingIndicatorReceivedEvent_then_dispatchTypingIndicatorReceivedAction() {
        let expectation = XCTestExpectation(description: "Dispatch Typing Indicator Received Action")
        func dispatch(action: Action) {
            switch action {
            case .participantsAction(.typingIndicatorReceived(_)):
                expectation.fulfill()
            default:
                XCTExpectFailure("typingIndicatorReceived was not dispatched")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatMessageReceivedEvent = ChatEventModel(
            eventType: .typingIndicatorReceived,
            infoModel: UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier("identifier"),
                                               timestamp: Iso8601Date())!)
        mockChatService.chatEventSubject.send(chatMessageReceivedEvent)
        wait(for: [expectation], timeout: 1)
    }
}

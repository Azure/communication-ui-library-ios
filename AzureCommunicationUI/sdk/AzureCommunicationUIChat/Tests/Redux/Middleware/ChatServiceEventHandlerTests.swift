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

    func test_chatServiceEventHandler_subscription_when_receiveRealTimeNotificationConnectedEvent_then_dispatchRealTimeNotificationConnectedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        func dispatch(action: Action) {
            switch action {
            case .chatAction(.realTimeNotificationConnected):
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatEventModel = ChatEventModel(
            eventType: .realTimeNotificationConnected)
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveRealTimeNotificationDisonnectedEvent_then_dispatchRealTimeNotificationDisonnectedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        func dispatch(action: Action) {
            switch action {
            case .chatAction(.realTimeNotificationDisconnected):
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatEventModel = ChatEventModel(
            eventType: .realTimeNotificationDisconnected)
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveChatMessageReceivedEvent_then_dispatchChatMessageReceivedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedMessageId = "messageId"
        func dispatch(action: Action) {
            switch action {
            case .repositoryAction(.chatMessageReceived(let message)):
                XCTAssertEqual(message.id, expectedMessageId)
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatEventModel = ChatEventModel(
            eventType: .chatMessageReceived,
            infoModel: ChatMessageInfoModel(id: "messageId"))
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveChatMessageEditedEvent_then_dispatchChatMessageEditedReceivedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedMessageId = "messageId"
        func dispatch(action: Action) {
            switch action {
            case .repositoryAction(.chatMessageEditedReceived(let message)):
                XCTAssertEqual(message.id, expectedMessageId)
                XCTAssertNotNil(message.editedOn)
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatEventModel = ChatEventModel(
            eventType: .chatMessageEdited,
            infoModel: ChatMessageInfoModel(id: "messageId",
                                            editedOn: Iso8601Date()))
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveChatMessageDeletedEvent_then_dispatchChatMessageDeletedReceivedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedMessageId = "messageId"
        func dispatch(action: Action) {
            switch action {
            case .repositoryAction(.chatMessageDeletedReceived(let message)):
                XCTAssertEqual(message.id, expectedMessageId)
                XCTAssertNotNil(message.deletedOn)
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatEventModel = ChatEventModel(
            eventType: .chatMessageDeleted,
            infoModel: ChatMessageInfoModel(id: "messageId",
                                            deletedOn: Iso8601Date()))
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveTypingIndicatorReceivedEvent_then_dispatchTypingIndicatorReceivedAction() {
        let expectation = XCTestExpectation(description: "Dispatch Typing Indicator Received Action")
        let expectedUserId = "identifier"
        func dispatch(action: Action) {
            switch action {
            case .participantsAction(.typingIndicatorReceived(let id, _)):
                XCTAssertEqual(id, expectedUserId)
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

    func test_chatServiceEventHandler_subscription_when_receiveTypingIndicatorReceivedEvent_then_dispatchClearTypingIndicatorAction() {
        let expectation = XCTestExpectation(description: "Dispatch Clearing Indicator Received Action")
        let expectedUserId = "identifier"
        func dispatch(action: Action) {
            switch action {
            case .participantsAction(.typingIndicatorReceived(_, let timer)):
                timer.fire()
            case .participantsAction(.clearTypingIndicator(let id)):
                XCTAssertEqual(id, expectedUserId)
                expectation.fulfill()
            default:
                XCTExpectFailure("clearTypingIndicator was not dispatched")
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

    func test_chatServiceEventHandler_subscription_when_receiveChatThreadDeletedEvent_then_dispatchChatThreadDeletedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        func dispatch(action: Action) {
            switch action {
            case .chatAction(.chatThreadDeleted):
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatEventModel = ChatEventModel(
            eventType: .chatThreadDeleted,
            infoModel: ChatThreadInfoModel(receivedOn: Iso8601Date()))
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveChatThreadPropertiesUpdatedEvent_then_dispatchChatTopicUpdatedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedTopic = "topic"
        func dispatch(action: Action) {
            switch action {
            case .chatAction(.chatTopicUpdated(let threadInfo)):
                XCTAssertEqual(threadInfo.topic, expectedTopic)
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let chatEventModel = ChatEventModel(
            eventType: .chatThreadPropertiesUpdated,
            infoModel: ChatThreadInfoModel(topic: "topic",
                                           receivedOn: Iso8601Date()))
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveParticipantsAddedEvent_then_dispatchParticipantsAddedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedUserId = "identifier"
        func dispatch(action: Action) {
            switch action {
            case .participantsAction(.participantsAdded(let participants)):
                XCTAssertEqual(participants.first?.identifier.stringValue, expectedUserId)
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let participant = ParticipantInfoModel(
            identifier: CommunicationUserIdentifier("identifier"),
            displayName: "DisplayName")
        let chatEventModel = ChatEventModel(
            eventType: .participantsAdded,
            infoModel: ParticipantsInfoModel(participants: [participant],
                                             createdOn: Iso8601Date()))
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }

    func test_chatServiceEventHandler_subscription_when_receiveParticipantsRemovedEvent_then_dispatchParticipantsRemovedAction() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedUserId = "identifier"
        func dispatch(action: Action) {
            switch action {
            case .participantsAction(.participantsRemoved(let participants)):
                XCTAssertEqual(participants.first?.identifier.stringValue, expectedUserId)
                expectation.fulfill()
            default:
                XCTExpectFailure("Should not reach default case.")
            }
        }
        chatServiceEventHandler.subscription(dispatch: dispatch)
        let participant = ParticipantInfoModel(
            identifier: CommunicationUserIdentifier("identifier"),
            displayName: "DisplayName")
        let chatEventModel = ChatEventModel(
            eventType: .participantsRemoved,
            infoModel: ParticipantsInfoModel(participants: [participant],
                                             createdOn: Iso8601Date()))
        mockChatService.chatEventSubject.send(chatEventModel)
        wait(for: [expectation], timeout: 1)
    }
}

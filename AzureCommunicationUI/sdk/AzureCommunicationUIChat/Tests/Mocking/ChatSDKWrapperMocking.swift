//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCommon
import AzureCore

@testable import AzureCommunicationUIChat

class ChatSDKWrapperMocking: ChatSDKWrapperProtocol {
    var error: NSError?
    var chatEventsHandler: ChatSDKEventsHandling = ChatSDKEventsHandler(
        logger: LoggerMocking(),
        threadId: "threadId",
        localUserId: CommunicationUserIdentifier("userId"))

    var initializeCalled = false
    var unregisterRealTimeNotificationCalled = false
    var getInitialMessagesCalled = false
    var retrieveChatThreadPropertiesCalled = false
    var getListOfParticipantsCalled = false
    var getPreviousMessagesCalled = false
    var sendMessageCalled = false
    var editMessageCalled = false
    var deleteMessageCalled = false
    var sendReadReceiptCalled = false
    var sendTypingIndicatorCalled = false

    func initializeChat() async throws {
        initializeCalled = true
        try await Task<Void, Error> {}.value
    }

    func getInitialMessages() async throws -> [ChatMessageInfoModel] {
        getInitialMessagesCalled = true
        return try await Task<[ChatMessageInfoModel], Error> {
            []
        }.value
    }

    func unregisterRealTimeNotifications() {
        unregisterRealTimeNotificationCalled = true
    }

    func retrieveChatThreadProperties() async throws -> ChatThreadInfoModel {
        retrieveChatThreadPropertiesCalled = true
        return try await Task<ChatThreadInfoModel, Error> {
            ChatThreadInfoModel(receivedOn: Iso8601Date())
        }.value
    }

    func getListOfParticipants() async throws -> [ParticipantInfoModel] {
        getListOfParticipantsCalled = true
        return try await Task<[ParticipantInfoModel], Error> {
            []
        }.value
    }

    func getPreviousMessages() async throws -> [ChatMessageInfoModel] {
        getPreviousMessagesCalled = true
        return try await Task<[ChatMessageInfoModel], Error> {
            []
        }.value
    }

    func sendMessage(content: String, senderDisplayName: String) async throws -> String {
        sendMessageCalled = true
        return try await Task<String, Error> {
            "messageId"
        }.value
    }

    func editMessage(messageId: String, content: String) async throws {
        editMessageCalled = true
        try await Task<Void, Error> {}.value
    }

    func deleteMessage(messageId: String) async throws {
        deleteMessageCalled = true
        try await Task<Void, Error> {}.value
    }

    func sendReadReceipt(messageId: String) async throws {
        sendReadReceiptCalled = true
        try await Task<Void, Error> {}.value
    }

    func sendTypingIndicator() async throws {
        sendTypingIndicatorCalled = true
        try await Task<Void, Error> {}.value
    }
}

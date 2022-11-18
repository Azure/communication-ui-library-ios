//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCommon
@testable import AzureCommunicationUIChat

class ChatSDKWrapperMocking: ChatSDKWrapperProtocol {
    var error: NSError?
    var chatEventsHandler: ChatSDKEventsHandling = ChatSDKEventsHandler(
        logger: LoggerMocking(),
        threadId: "threadId",
        localUserId: CommunicationUserIdentifier("userId"))

    var initializeCalled: Bool = false
    var getInitialMessagesCalled: Bool = false
    var retrieveThreadCreatedByCalled: Bool = false
    var getListOfParticipantsCalled: Bool = false
    var getPreviousMessagesCalled: Bool = false
    var sendMessageCalled: Bool = false
    var editMessageCalled: Bool = false
    var deleteMessageCalled: Bool = false
    var sendReadReceiptCalled: Bool = false
    var sendTypingIndicatorCalled: Bool = false

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

    func retrieveThreadCreatedBy() async throws -> String {
        retrieveThreadCreatedByCalled = true
        return try await Task<String, Error> {
            "participantId"
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

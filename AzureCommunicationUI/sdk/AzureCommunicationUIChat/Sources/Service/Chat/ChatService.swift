//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol ChatServiceProtocol {
    func initialize() async throws
    func disconnectChatService() async throws
    func getInitialMessages() async throws -> [ChatMessageInfoModel]
    func getMaskedParticipantIds() async throws -> Set<String>
    func getListOfParticipants() async throws -> [ParticipantInfoModel]
    func getPreviousMessages() async throws -> [ChatMessageInfoModel]
    func sendMessage(content: String, senderDisplayName: String) async throws -> String
    func editMessage(messageId: String, content: String) async throws
    func deleteMessage(messageId: String) async throws
    func sendReadReceipt(messageId: String) async throws
    func sendTypingIndicator() async throws

    var chatEventSubject: PassthroughSubject<ChatEventModel, Never> { get }
}

class ChatService: NSObject, ChatServiceProtocol {
    private let logger: Logger
    private let chatSDKWrapper: ChatSDKWrapperProtocol

    var chatEventSubject: PassthroughSubject<ChatEventModel, Never>

    init(logger: Logger,
         chatSDKWrapper: ChatSDKWrapperProtocol ) {
        self.logger = logger
        self.chatSDKWrapper = chatSDKWrapper
        self.chatEventSubject = chatSDKWrapper.chatEventsHandler.chatEventSubject
    }

    func initialize() async throws {
        try await chatSDKWrapper.initializeChat()
    }

    func disconnectChatService() async throws {
        try await chatSDKWrapper.unregisterRealTimeNotifications()
    }
    func getInitialMessages() async throws -> [ChatMessageInfoModel] {
        return try await chatSDKWrapper.getInitialMessages()
    }

    func getMaskedParticipantIds() async throws -> Set<String> {
        guard let createdBy = try await chatSDKWrapper.retrieveChatThreadProperties().createdBy else {
            return Set<String>()
        }
        let maskedParticipantIdsSet: Set = [createdBy]
        return maskedParticipantIdsSet
    }

    func getListOfParticipants() async throws -> [ParticipantInfoModel] {
        return try await chatSDKWrapper.getListOfParticipants()
    }
    func getPreviousMessages() async throws -> [ChatMessageInfoModel] {
        return try await chatSDKWrapper.getPreviousMessages()
    }

    func sendMessage(content: String, senderDisplayName: String) async throws -> String {
        return try await chatSDKWrapper.sendMessage(content: content, senderDisplayName: senderDisplayName)
    }

    func editMessage(messageId: String, content: String) async throws {
        try await chatSDKWrapper.editMessage(messageId: messageId, content: content)
    }

    func deleteMessage(messageId: String) async throws {
        try await chatSDKWrapper.deleteMessage(messageId: messageId)
    }

    func sendReadReceipt(messageId: String) async throws {
        try await chatSDKWrapper.sendReadReceipt(messageId: messageId)
    }

    func sendTypingIndicator() async throws {
        try await chatSDKWrapper.sendTypingIndicator()
    }
}

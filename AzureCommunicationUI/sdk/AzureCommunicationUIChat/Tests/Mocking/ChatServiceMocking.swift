//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
@testable import AzureCommunicationUIChat

class ChatServiceMocking: ChatServiceProtocol {
    var error: Error?
    var chatEventSubject = PassthroughSubject<ChatEventModel, Never>()

    var topic: String = "topic"
    var initialMessages: [ChatMessageInfoModel] = []
    var listOfParticipants: [ParticipantInfoModel] = []
    var previousMessages: [ChatMessageInfoModel] = []

    var initializeCalled: Bool = false
    var getInitialMessagesCalled: Bool = false
    var getListOfParticipantsCalled: Bool = false
    var getPreviousMessagesCalled: Bool = false
    var sendMessageCalled: Bool = false
    var editMessageCalled: Bool = false
    var deleteMessageCalled: Bool = false
    var sendReadReceiptCalled: Bool = false
    var sendTypingIndicatorCalled: Bool = false

    func initalize() async throws {
        initializeCalled = true
        try await possibleErrorTask().value
    }

    func getInitialMessages() async throws -> [ChatMessageInfoModel] {
        getInitialMessagesCalled = true
        let task = Task<[ChatMessageInfoModel], Error> {
            if let error = self.error {
                throw error
            }
            return initialMessages
        }
        return try await task.value
    }

    func getListOfParticipants() async throws -> [AzureCommunicationUIChat.ParticipantInfoModel] {
        getListOfParticipantsCalled = true
        let task = Task<[ParticipantInfoModel], Error> {
            if let error = self.error {
                throw error
            }
            return listOfParticipants
        }
        return try await task.value
    }

    func getPreviousMessages() async throws -> [ChatMessageInfoModel] {
        getPreviousMessagesCalled = true
        let task = Task<[ChatMessageInfoModel], Error> {
            if let error = self.error {
                throw error
            }
            return previousMessages
        }
        return try await task.value
    }

    func sendMessage(content: String, senderDisplayName: String) async throws -> String {
        sendMessageCalled = true
        let task = Task<String, Error> {
            if let error = self.error {
                throw error
            }
            return "messageId"
        }
        return try await task.value
    }

    func editMessage(messageId: String, content: String) async throws {
        editMessageCalled = true
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
        }
    }

    func deleteMessage(messageId: String) async throws {
        deleteMessageCalled = true
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
        }
    }

    func sendReadReceipt(messageId: String) async throws {
        sendReadReceiptCalled = true
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
        }
    }

    // for future void functions
    private func possibleErrorTask() throws -> Task<Void, Error> {
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
        }
    }

    func sendTypingIndicator() async throws {
        sendTypingIndicatorCalled = true
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
        }
    }
}

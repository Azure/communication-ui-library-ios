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

    var initializeCalled: Bool = false
    var getInitialMessagesCalled: Bool = false
    var sendMessageCalled: Bool = false

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

    func sendReadReceipt(messageId: String) async throws {
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
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
@testable import AzureCommunicationUIChat

class ChatServiceMocking: ChatServiceProtocol {
    var error: Error?

    var topic: String = "topic"
    var initialMessages: [ChatMessageInfoModel] = []

    var initializeCalled: Bool = false
    var getInitialMessagesCalled: Bool = false

    func initalize() async throws -> String {
        initializeCalled = true
        try await possibleErrorTask().value
        let task = Task<String, Error> {
            if let error = self.error {
                throw error
            }
            return self.topic
        }
        return try await task.value
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

    // for future void functions
    private func possibleErrorTask() throws -> Task<Void, Error> {
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
        }
    }
}

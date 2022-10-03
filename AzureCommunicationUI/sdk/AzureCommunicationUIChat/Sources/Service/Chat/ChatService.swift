//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol ChatServiceProtocol {
    func initalize() async throws -> String
    func getInitialMessages() async throws -> [ChatMessageInfoModel]
}

class ChatService: NSObject, ChatServiceProtocol {

    private let logger: Logger
    private let chatSDKWrapper: ChatSDKWrapperProtocol

    init(logger: Logger,
         chatSDKWrapper: ChatSDKWrapperProtocol ) {
        self.logger = logger
        self.chatSDKWrapper = chatSDKWrapper
    }

    func initalize() async throws -> String {
        return try await chatSDKWrapper.initializeChat()
    }

    func getInitialMessages() async throws -> [ChatMessageInfoModel] {
        return try await chatSDKWrapper.getInitialMessages()
    }

}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol ChatServiceProtocol {
    func initalize() async throws
    func getInitialMessages() async throws -> [ChatMessageInfoModel]

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

    func initalize() async throws {
        try await chatSDKWrapper.initializeChat()
    }

    func getInitialMessages() async throws -> [ChatMessageInfoModel] {
        return try await chatSDKWrapper.getInitialMessages()
    }

}

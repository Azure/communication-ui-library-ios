//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ChatServiceProtocol {
    func chatStart() async throws -> [ChatMessageInfoModel]
}

class ChatService: NSObject, ChatServiceProtocol {
    private let logger: Logger
    private let chatSDKWrapper: ChatSDKWrapperProtocol

    init(logger: Logger,
         chatSDKWrapper: ChatSDKWrapperProtocol ) {
        self.logger = logger
        self.chatSDKWrapper = chatSDKWrapper
    }

    func chatStart() async throws -> [ChatMessageInfoModel] {
        return try await chatSDKWrapper.chatStart()
    }
}

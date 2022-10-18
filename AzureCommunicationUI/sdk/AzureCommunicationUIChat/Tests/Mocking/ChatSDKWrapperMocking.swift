//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
@_spi(common) import AzureCommunicationUICommon
import Combine
import Foundation
@testable import AzureCommunicationUIChat

class ChatSDKWrapperMocking: ChatSDKWrapperProtocol {
    var error: NSError?
    var chatEventsHandler: ChatSDKEventsHandling = ChatSDKEventsHandler(
        logger: LoggerMocking(),
        threadId: "threadId",
        localUserId: CommunicationUserIdentifier("userId"))

    var initializeCalled: Bool = false
    var getInitialMessagesCalled: Bool = false
    var sendMessageCalled: Bool = false

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

    func sendMessage(content: String, senderDisplayName: String) async throws -> String {
        sendMessageCalled = true
        return try await Task<String, Error> {
            "messageId"
        }.value
    }
}

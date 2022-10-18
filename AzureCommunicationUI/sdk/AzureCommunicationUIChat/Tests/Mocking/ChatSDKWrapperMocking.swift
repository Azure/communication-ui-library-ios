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
    var sendMessageCalled: Bool = false
    var sendReadReceiptCalled: Bool = false

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

    func sendReadReceipt(messageId: String) async throws {
        sendReadReceiptCalled = true
        try await Task<Void, Error> {}.value
    }
}

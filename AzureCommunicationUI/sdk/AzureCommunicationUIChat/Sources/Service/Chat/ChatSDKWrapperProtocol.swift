//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import Combine

protocol ChatSDKWrapperProtocol {
    func initializeChat() async throws
    func getInitialMessages() async throws -> [ChatMessageInfoModel]
    func getListOfParticipants() async throws -> [ParticipantInfoModel]
    func getPreviousMessages() async throws -> [ChatMessageInfoModel]
    func sendMessage(content: String, senderDisplayName: String) async throws -> String
    func sendReadReceipt(messageId: String) async throws
    func sendTypingIndicator() async throws

    var chatEventsHandler: ChatSDKEventsHandling { get }
}

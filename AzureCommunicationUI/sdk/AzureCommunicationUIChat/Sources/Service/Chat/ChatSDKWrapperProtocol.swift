//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationChat

protocol ChatSDKWrapperProtocol {
    func chatStart() -> AnyPublisher<[ChatMessageInfoModel], Error>

    func sendTypingIndicator() -> AnyPublisher<Void, Error>
    func sendMessageRead(messageId: String) -> AnyPublisher<Void, Error>

    func sendMessage(message: ChatMessageInfoModel) -> AnyPublisher<String, Error>
    func editMessage(message: ChatMessageInfoModel) -> AnyPublisher<Void, Error>
    func deleteMessage(messageId: String) -> AnyPublisher<Void, Error>

    func fetchPreviousMessages() -> AnyPublisher<[ChatMessageInfoModel], Error>

    func listParticipants() -> AnyPublisher<[ParticipantInfoModel], Error>
    func removeParticipant(participant: ParticipantInfoModel) -> AnyPublisher<Void, Error>
    func removeLocalParticipant() -> AnyPublisher<Void, Error>

    var chatEventsHandler: ChatSDKEventsHandling { get }
}

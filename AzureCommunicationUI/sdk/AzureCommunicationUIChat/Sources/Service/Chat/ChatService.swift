//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ChatServiceProtocol {

    var typingIndicatorSubject: PassthroughSubject<UserEventTimestampModel, Never> { get }
    var readReceiptSubject: PassthroughSubject<UserEventTimestampModel, Never> { get }

    var chatMessageReceivedSubject: PassthroughSubject<ChatMessageInfoModel, Never> { get }
    var chatMessageEditedSubject: PassthroughSubject<ChatMessageInfoModel, Never> { get }
    var chatMessageDeletedSubject: PassthroughSubject<ChatMessageInfoModel, Never> { get }

    var chatThreadTopicSubject: PassthroughSubject<String, Never> { get }
    var chatThreadDeletedSubject: PassthroughSubject<String, Never> { get }
    var participantsAddedSubject: PassthroughSubject<[ParticipantInfoModel], Never> { get }
    var participantsRemovedSubject: PassthroughSubject<[ParticipantInfoModel], Never> { get }

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
}

class ChatService: NSObject, ChatServiceProtocol {
    private let logger: Logger
    private let chatSDKWrapper: ChatSDKWrapperProtocol

    var typingIndicatorSubject: PassthroughSubject<UserEventTimestampModel, Never>
    var readReceiptSubject: PassthroughSubject<UserEventTimestampModel, Never>

    var chatMessageReceivedSubject: PassthroughSubject<ChatMessageInfoModel, Never>
    var chatMessageEditedSubject: PassthroughSubject<ChatMessageInfoModel, Never>
    var chatMessageDeletedSubject: PassthroughSubject<ChatMessageInfoModel, Never>

    var chatThreadTopicSubject: PassthroughSubject<String, Never>
    var chatThreadDeletedSubject: PassthroughSubject<String, Never>
    var participantsAddedSubject: PassthroughSubject<[ParticipantInfoModel], Never>
    var participantsRemovedSubject: PassthroughSubject<[ParticipantInfoModel], Never>

    init(logger: Logger,
         chatSDKWrapper: ChatSDKWrapperProtocol ) {
        self.logger = logger
        self.chatSDKWrapper = chatSDKWrapper

        typingIndicatorSubject = chatSDKWrapper.chatEventsHandler.typingIndicatorSubject
        readReceiptSubject = chatSDKWrapper.chatEventsHandler.readReceiptSubject

        chatMessageReceivedSubject = chatSDKWrapper.chatEventsHandler.chatMessageReceivedSubject
        chatMessageEditedSubject = chatSDKWrapper.chatEventsHandler.chatMessageEditedSubject
        chatMessageDeletedSubject = chatSDKWrapper.chatEventsHandler.chatMessageDeletedSubject

        chatThreadTopicSubject = chatSDKWrapper.chatEventsHandler.chatThreadTopicSubject
        chatThreadDeletedSubject = chatSDKWrapper.chatEventsHandler.chatThreadDeletedSubject
        participantsAddedSubject = chatSDKWrapper.chatEventsHandler.participantsAddedSubject
        participantsRemovedSubject = chatSDKWrapper.chatEventsHandler.participantsRemovedSubject
    }

    func chatStart() -> AnyPublisher<[ChatMessageInfoModel], Error> {
        return chatSDKWrapper.chatStart()
    }

    func sendTypingIndicator() -> AnyPublisher<Void, Error> {
        return chatSDKWrapper.sendTypingIndicator()
    }

    func sendMessageRead(messageId: String) -> AnyPublisher<Void, Error> {
        return chatSDKWrapper.sendMessageRead(messageId: messageId)
    }

    func sendMessage(message: ChatMessageInfoModel) -> AnyPublisher<String, Error> {
        return chatSDKWrapper.sendMessage(message: message)
    }

    func editMessage(message: ChatMessageInfoModel) -> AnyPublisher<Void, Error> {
        return chatSDKWrapper.editMessage(message: message)
    }

    func deleteMessage(messageId: String) -> AnyPublisher<Void, Error> {
        return chatSDKWrapper.deleteMessage(messageId: messageId)
    }

    func fetchPreviousMessages() -> AnyPublisher<[ChatMessageInfoModel], Error> {
        return chatSDKWrapper.fetchPreviousMessages()
    }

    func listParticipants() -> AnyPublisher<[ParticipantInfoModel], Error> {
        return chatSDKWrapper.listParticipants()
    }

    func removeParticipant(participant: ParticipantInfoModel) -> AnyPublisher<Void, Error> {
        return chatSDKWrapper.removeParticipant(participant: participant)
    }

    func removeLocalParticipant() -> AnyPublisher<Void, Error> {
        return chatSDKWrapper.removeLocalParticipant()
    }
}

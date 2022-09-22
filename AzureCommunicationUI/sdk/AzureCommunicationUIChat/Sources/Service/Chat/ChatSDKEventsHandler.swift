//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationChat
import AzureCommunicationCommon

// chatMessageReceivedEvent(_:)
// typingIndicatorReceived(_:)
// readReceiptReceived(_:)
// chatMessageEdited(_:)
// chatMessageDeleted(_:)
// chatThreadPropertiesUpdated(_:)
// chatThreadDeleted(_:) - need
// participantsAdded(_:) - need
// participantsRemoved(_:) - need

protocol ChatSDKEventsHandling {
    func handle(response: TrouterEvent)

    var typingIndicatorSubject: PassthroughSubject<UserEventTimestampModel, Never> { get }
    var readReceiptSubject: PassthroughSubject<UserEventTimestampModel, Never> { get }

    var chatMessageReceivedSubject: PassthroughSubject<ChatMessageInfoModel, Never> { get }
    var chatMessageEditedSubject: PassthroughSubject<ChatMessageInfoModel, Never> { get }
    var chatMessageDeletedSubject: PassthroughSubject<ChatMessageInfoModel, Never> { get }

    var chatThreadTopicSubject: PassthroughSubject<String, Never> { get }
    var chatThreadDeletedSubject: PassthroughSubject<String, Never> { get }
    var participantsAddedSubject: PassthroughSubject<[ParticipantInfoModel], Never> { get }
    var participantsRemovedSubject: PassthroughSubject<[ParticipantInfoModel], Never> { get }
}

class ChatSDKEventsHandler: NSObject, ChatSDKEventsHandling {
    private let logger: Logger
    private let threadId: String
    private let localUserId: CommunicationIdentifier

    var typingIndicatorSubject = PassthroughSubject<UserEventTimestampModel, Never>()
    var readReceiptSubject = PassthroughSubject<UserEventTimestampModel, Never>()

    var chatMessageReceivedSubject = PassthroughSubject<ChatMessageInfoModel, Never>()
    var chatMessageEditedSubject = PassthroughSubject<ChatMessageInfoModel, Never>()
    var chatMessageDeletedSubject = PassthroughSubject<ChatMessageInfoModel, Never>()

    var chatThreadTopicSubject = PassthroughSubject<String, Never>()
    var chatThreadDeletedSubject = PassthroughSubject<String, Never>()
    var participantsAddedSubject = PassthroughSubject<[ParticipantInfoModel], Never>()
    var participantsRemovedSubject = PassthroughSubject<[ParticipantInfoModel], Never>()

    init(logger: Logger,
         threadId: String,
         localUserId: CommunicationIdentifier) {
        self.logger = logger
        self.threadId = threadId
        self.localUserId = localUserId
    }

    func handle(response: TrouterEvent) {
        switch response {
        case let .typingIndicatorReceived(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a TypingIndicatorReceivedEvent: \(event)")
            chat(didReceiveTypingIndicator: event)
        case let .readReceiptReceived(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ReadReceiptReceivedEvent: \(event)")
            chat(didReceiveReadReceipt: event)
        case let .chatMessageReceivedEvent(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ChatMessageReceivedEvent: \(event)")
            chat(didReceiveChatMessage: event)
        case let .chatMessageEdited(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ChatMessageEditedEvent: \(event)")
            chat(didReceiveChatMessageEdited: event)
        case let .chatMessageDeleted(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ChatMessageDeletedEvent: \(event)")
            chat(didReceiveChatMessageDeleted: event)
        case let .chatThreadPropertiesUpdated(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ChatThreadPropertiesUpdatedEvent: \(event)")
            chat(didReceiveChatThreadPropertyUpdated: event)
        case let .chatThreadDeleted(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ChatThreadDeletedEvent: \(event)")
            chat(didReceiveChatThreadDeleted: event)
        case let .participantsAdded(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ParticipantsAddedEvent: \(event)")
            chat(didReceiveParticipantAdded: event)
        case let .participantsRemoved(event):
            guard event.threadId == self.threadId else {
                return
            }
            print("Received a ParticipantsRemovedEvent: \(event)")
            chat(didReceiveParticipantRemoved: event)
        default:
            print("Event received will not handled \(response)")
            return
        }
    }

    func chat(didReceiveTypingIndicator event: TypingIndicatorReceivedEvent) {
        //  -> UserEventTimestampModel

        if event.sender?.stringValue != self.localUserId.stringValue {
            let userEventTimestamp = event.toUserEventTimestampModel()
            typingIndicatorSubject.send(userEventTimestamp)
        }
    }

    func chat(didReceiveReadReceipt event: ReadReceiptReceivedEvent) {
        //  -> UserEventTimestampModel
        let userEventTimestamp = event.toUserEventTimestampModel()
        readReceiptSubject.send(userEventTimestamp)
    }

    func chat(didReceiveChatMessage event: ChatMessageReceivedEvent) {
        // -> ChatMessageInfoModel
        let chatMessage = event.toChatMessageInfoModel()
        print("didReceiveChatMessage: \(String(describing: chatMessage.content))")
        chatMessageReceivedSubject.send(chatMessage)
    }

    func chat(didReceiveChatMessageEdited event: ChatMessageEditedEvent) {
        //  -> ChatMessageInfoModel
        let chatMessage = event.toChatMessageInfoModel()

        chatMessageEditedSubject.send(chatMessage)
    }

    func chat(didReceiveChatMessageDeleted event: ChatMessageDeletedEvent) {
        // -> ChatMessageInfoModel
        let chatMessage = event.toChatMessageInfoModel()

        chatMessageDeletedSubject.send(chatMessage)
    }

    func chat(didReceiveChatThreadPropertyUpdated event: ChatThreadPropertiesUpdatedEvent) {
        // -> String
        chatThreadTopicSubject.send(event.properties?.topic ?? "")
    }

    func chat(didReceiveChatThreadDeleted event: ChatThreadDeletedEvent) {
        // -> Void
        chatThreadDeletedSubject.send(event.threadId)
    }

    func chat(didReceiveParticipantAdded event: ParticipantsAddedEvent) {
        //  -> [ParticipantInfoModel]
        guard let participantsToAdd = event.participantsAdded else {
            return
        }
        let participants = participantsToAdd.map {
            $0.toParticipantInfoModel()
        }
        participantsAddedSubject.send(participants)
    }

    func chat(didReceiveParticipantRemoved event: ParticipantsRemovedEvent) {
        // -> [ParticipantInfoModel]
        guard let participantsToRemove = event.participantsRemoved else {
            return
        }
        let participants = participantsToRemove.map {
            $0.toParticipantInfoModel()
        }
        participantsRemovedSubject.send(participants)
    }
}

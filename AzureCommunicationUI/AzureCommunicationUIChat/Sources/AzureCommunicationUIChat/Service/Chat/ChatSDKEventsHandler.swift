//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCommunicationCommon
@_spi(common) import AzureCommunicationUICommon
import Combine
import Foundation

protocol ChatSDKEventsHandling {
    func handle(response: TrouterEvent)
    var chatEventSubject: PassthroughSubject<ChatEventModel, Never> { get }
}

class ChatSDKEventsHandler: NSObject, ChatSDKEventsHandling {
    private let logger: Logger
    private let threadId: String
    private let localUserId: CommunicationIdentifier

    var chatEventSubject = PassthroughSubject<ChatEventModel, Never>()

    init(logger: Logger,
         threadId: String,
         localUserId: CommunicationIdentifier) {
        self.logger = logger
        self.threadId = threadId
        self.localUserId = localUserId
    }

    func handle(response: TrouterEvent) {
        var eventModel: ChatEventModel?
        switch response {
        case .realTimeNotificationConnected:
            logger.info("Received a RealTimeNotificationConnected event")
            eventModel = ChatEventModel(
                eventType: .realTimeNotificationConnected)
        case .realTimeNotificationDisconnected:
            logger.info("Received a RealTimeNotificationDisconnected event")
            eventModel = ChatEventModel(
                eventType: .realTimeNotificationDisconnected)
        case let .chatMessageReceivedEvent(event):
            logger.info("Received a ChatMessageReceivedEvent: \(event.type)")
            eventModel = ChatEventModel(
                eventType: .chatMessageReceived,
                infoModel: event.toChatMessageInfoModel())
        case let .chatMessageEdited(event):
            logger.info("Received a ChatMessageEditedEvent: \(event)")
            eventModel = ChatEventModel(
                eventType: .chatMessageEdited,
                infoModel: event.toChatMessageInfoModel())
        case let .chatMessageDeleted(event):
            logger.info("Received a ChatMessageDeletedEvent: \(event)")
            eventModel = ChatEventModel(
                eventType: .chatMessageDeleted,
                infoModel: event.toChatMessageInfoModel())
        case let .typingIndicatorReceived(event):
            logger.info("Received a TypingIndicatorReceivedEvent: \(event)")
            guard event.threadId == self.threadId,
                let userEventTimestamp = event.toUserEventTimestampModel() else {
                return
            }
            eventModel = ChatEventModel(eventType: .typingIndicatorReceived,
                                        infoModel: userEventTimestamp)
        case let .readReceiptReceived(event):
            // Stub: not implemented
            logger.info("Received a ReadReceiptReceivedEvent: \(event)")
        case let .chatThreadDeleted(event):
            logger.info("Received a ChatThreadDeletedEvent: \(event)")
            eventModel = ChatEventModel(
                eventType: .chatThreadDeleted,
                infoModel: event.toChatThreadInfoModel())
        case let .chatThreadPropertiesUpdated(event):
            logger.info("Received a ChatThreadPropertiesUpdatedEvent: \(event)")
            eventModel = ChatEventModel(
                eventType: .chatThreadPropertiesUpdated,
                infoModel: event.toChatThreadInfoModel())
        case let .participantsAdded(event):
            logger.info("Received a ParticipantsAddedEvent: \(event)")
            guard let participants = event.participantsAdded else {
                return
            }
            eventModel = ChatEventModel(
                eventType: .participantsAdded,
                infoModel: event.toParticipantsInfo(participants))
        case let .participantsRemoved(event):
            logger.info("Received a ParticipantsRemovedEvent: \(event)")
            guard let participants = event.participantsRemoved else {
                return
            }
            eventModel = ChatEventModel(
                eventType: .participantsRemoved,
                infoModel: event.toParticipantsInfo(participants))
        default:
            logger.info("Event received will not handled \(response)")
            return
        }

        guard let chatEventModel = eventModel else {
            return
        }
        chatEventSubject.send(chatEventModel)
    }
}

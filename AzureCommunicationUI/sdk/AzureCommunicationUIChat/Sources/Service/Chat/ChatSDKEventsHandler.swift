//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCommunicationCommon
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
            eventModel = ChatEventModel(
                eventType: .chatMessageReceived,
                infoModel: event.toChatMessageInfoModel(),
                threadId: event.threadId)
        case let .chatMessageEdited(event):
            eventModel = ChatEventModel(
                eventType: .chatMessageEdited,
                infoModel: event.toChatMessageInfoModel(),
                threadId: event.threadId)
        case let .chatMessageDeleted(event):
            eventModel = ChatEventModel(
                eventType: .chatMessageDeleted,
                infoModel: event.toChatMessageInfoModel(),
                threadId: event.threadId)
        case let .typingIndicatorReceived(event):
            guard event.threadId == self.threadId,
                  let userEventTimestamp = event.toUserEventTimestampModel(),
                    userEventTimestamp.id != localUserId.stringValue else {
                return
            }
            eventModel = ChatEventModel(eventType: .typingIndicatorReceived,
                                        infoModel: userEventTimestamp,
                                        threadId: event.threadId)
        case let .readReceiptReceived(event):
            eventModel = ChatEventModel(eventType: .readReceiptReceived,
                                        infoModel: event.toReadReceiptInfoModel(),
                                        threadId: event.threadId)
        case let .chatThreadDeleted(event):
            eventModel = ChatEventModel(
                eventType: .chatThreadDeleted,
                infoModel: event.toChatThreadInfoModel(),
                threadId: event.threadId)
        case let .chatThreadPropertiesUpdated(event):
            eventModel = ChatEventModel(
                eventType: .chatThreadPropertiesUpdated,
                infoModel: event.toChatThreadInfoModel(),
                threadId: event.threadId)
        case let .participantsAdded(event):
            guard let participants = event.participantsAdded else {
                return
            }
            eventModel = ChatEventModel(
                eventType: .participantsAdded,
                infoModel: event.toParticipantsInfo(participants,
                                                    localUserId.stringValue),
                threadId: event.threadId)
        case let .participantsRemoved(event):
            guard let participants = event.participantsRemoved else {
                return
            }
            eventModel = ChatEventModel(
                eventType: .participantsRemoved,
                infoModel: event.toParticipantsInfo(participants,
                                                    localUserId.stringValue),
                threadId: event.threadId)
        default:
            logger.info("Event received will not handled \(response)")
            return
        }

        guard let chatEventModel = eventModel else {
            return
        }
        if let threadId = chatEventModel.threadId,
           threadId != self.threadId {
            return
        }
        chatEventSubject.send(chatEventModel)
    }
}

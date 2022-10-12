//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol ChatServiceEventHandling {
    func subscription(dispatch: @escaping ActionDispatch)
}

class ChatServiceEventHandler: ChatServiceEventHandling {
    private let chatService: ChatServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    func subscription(dispatch: @escaping ActionDispatch) {
        logger.debug("Subscribe to chat service subjects")

        chatService.chatEventSubject
            .sink { [weak self] chatEvent in
                let eventType = chatEvent.eventType
                let infoModel = chatEvent.infoModel
                guard let self = self else {
                    return
                }

                switch (eventType, infoModel) {
                case (.realTimeNotificationConnected, _):
                    self.handleRealTimeNotificationConnected(dispatch: dispatch)
                case (.realTimeNotificationDisconnected, _):
                    self.handleRealTimeNotificationDisconnected(dispatch: dispatch)
                case (.chatMessageReceived,
                      let chatMessage as ChatMessageInfoModel):
                    self.handleChatMessageReceived(dispatch: dispatch, chatMessage: chatMessage)
                case (.chatMessageEdited,
                      let chatMessage as ChatMessageInfoModel):
                    self.handleChatMessageEdited(dispatch: dispatch, chatMessage: chatMessage)
                case (.chatMessageDeleted,
                      let chatMessage as ChatMessageInfoModel):
                    self.handleChatMessageDeleted(dispatch: dispatch, chatMessage: chatMessage)
                case (.typingIndicatorReceived,
                      let userEventTimestamp as UserEventTimestampModel):
                    self.handleTypingIndicatorReceived(dispatch: dispatch, userEventTimestamp: userEventTimestamp)
                case (.readReceiptReceived,
                      let userEventTimestamp as UserEventTimestampModel):
                    self.handleReadReceiptReceived(dispatch: dispatch, userEventTimestamp: userEventTimestamp)
                case (.chatThreadDeleted,
                      let chatThreadInfo as ChatThreadInfoModel):
                    self.handleChatThreadDeleted(dispatch: dispatch, threadInfo: chatThreadInfo)
                case (.chatThreadPropertiesUpdated,
                      let chatThreadInfo as ChatThreadInfoModel):
                    self.handleChatThreadPropertiesUpdated(dispatch: dispatch, threadInfo: chatThreadInfo)
                case (.participantsAdded,
                      let participantsInfo as ParticipantsInfoModel):
                    self.handleParticipantsAdded(dispatch: dispatch, participantsInfo: participantsInfo)
                case (.participantsRemoved,
                      let participantsInfo as ParticipantsInfoModel):
                    self.handleParticipantsRemoved(dispatch: dispatch, participantsInfo: participantsInfo)
                default:
                    print("ChatServiceEventHandler subscription switch: default case")
                }
            }.store(in: cancelBag)
    }

    func handleRealTimeNotificationConnected(dispatch: @escaping ActionDispatch) {
        dispatch(.chatAction(.realTimeNotificationConnected))
    }

    func handleRealTimeNotificationDisconnected(dispatch: @escaping ActionDispatch) {
        dispatch(.chatAction(.realTimeNotificationDisconnected))
    }

    func handleChatMessageReceived(dispatch: @escaping ActionDispatch,
                                   chatMessage: ChatMessageInfoModel) {
        dispatch(.repositoryAction(.chatMessageReceived(message: chatMessage)))
    }

    func handleChatMessageEdited(dispatch: @escaping ActionDispatch,
                                 chatMessage: ChatMessageInfoModel) {
        // stub: to be implemented
    }

    func handleChatMessageDeleted(dispatch: @escaping ActionDispatch,
                                  chatMessage: ChatMessageInfoModel) {
        // stub: to be implemented
    }

    func handleTypingIndicatorReceived(dispatch: @escaping ActionDispatch,
                                       userEventTimestamp: UserEventTimestampModel) {
        dispatch(.participantsAction(.typingIndicatorReceived(userEventTimestamp: userEventTimestamp)))
    }

    func handleReadReceiptReceived(dispatch: @escaping ActionDispatch,
                                   userEventTimestamp: UserEventTimestampModel) {
        // stub: to be implemented
    }

    func handleChatThreadDeleted(dispatch: @escaping ActionDispatch,
                                 threadInfo: ChatThreadInfoModel) {
        dispatch(.chatAction(.chatThreadDeleted))
    }

    func handleChatThreadPropertiesUpdated(dispatch: @escaping ActionDispatch,
                                           threadInfo: ChatThreadInfoModel) {
        guard let topic = threadInfo.topic else {
            return
        }
        dispatch(.chatAction(.chatTopicUpdated(topic: topic)))
    }

    func handleParticipantsAdded(dispatch: @escaping ActionDispatch,
                                 participantsInfo: ParticipantsInfoModel) {
        dispatch(.participantsAction(.participantsAdded(participants: participantsInfo.participants)))

    }

    func handleParticipantsRemoved(dispatch: @escaping ActionDispatch,
                                   participantsInfo: ParticipantsInfoModel) {
        dispatch(.participantsAction(.participantsRemoved(participants: participantsInfo.participants)))
    }
}

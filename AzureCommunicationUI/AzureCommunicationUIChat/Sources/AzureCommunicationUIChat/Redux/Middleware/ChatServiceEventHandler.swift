//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
@_spi(common) import AzureCommunicationUICommon
import Foundation

protocol ChatServiceEventHandling {
    func subscription(dispatch: @escaping ChatActionDispatch)
}

class ChatServiceEventHandler: ChatServiceEventHandling {
    private let chatService: ChatServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    func subscription(dispatch: @escaping ChatActionDispatch) {
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
                    self.logger.warning("ChatServiceEventHandler subscription switch: default case")
                }
            }.store(in: cancelBag)
    }

    func handleRealTimeNotificationConnected(dispatch: @escaping ChatActionDispatch) {
        dispatch(.chatAction(.realTimeNotificationConnected))
    }

    func handleRealTimeNotificationDisconnected(dispatch: @escaping ChatActionDispatch) {
        dispatch(.chatAction(.realTimeNotificationDisconnected))
    }

    func handleChatMessageReceived(dispatch: @escaping ChatActionDispatch,
                                   chatMessage: ChatMessageInfoModel) {
        dispatch(.repositoryAction(.chatMessageReceived(message: chatMessage)))
    }

    func handleChatMessageEdited(dispatch: @escaping ChatActionDispatch,
                                 chatMessage: ChatMessageInfoModel) {
        dispatch(.repositoryAction(.chatMessageEditedReceived(message: chatMessage)))
    }

    func handleChatMessageDeleted(dispatch: @escaping ChatActionDispatch,
                                  chatMessage: ChatMessageInfoModel) {
        dispatch(.repositoryAction(.chatMessageDeletedReceived(message: chatMessage)))
    }

    func handleTypingIndicatorReceived(dispatch: @escaping ChatActionDispatch,
                                       userEventTimestamp: UserEventTimestampModel) {
        dispatch(.participantsAction(.typingIndicatorReceived(userEventTimestamp: userEventTimestamp)))
    }

    func handleReadReceiptReceived(dispatch: @escaping ChatActionDispatch,
                                   userEventTimestamp: UserEventTimestampModel) {
        // stub: to be implemented
    }

    func handleChatThreadDeleted(dispatch: @escaping ChatActionDispatch,
                                 threadInfo: ChatThreadInfoModel) {
        dispatch(.chatAction(.chatThreadDeleted))
    }

    func handleChatThreadPropertiesUpdated(dispatch: @escaping ChatActionDispatch,
                                           threadInfo: ChatThreadInfoModel) {
        guard let topic = threadInfo.topic else {
            return
        }
        dispatch(.chatAction(.chatTopicUpdated(topic: topic)))
    }

    func handleParticipantsAdded(dispatch: @escaping ChatActionDispatch,
                                 participantsInfo: ParticipantsInfoModel) {
        dispatch(.participantsAction(.participantsAdded(participants: participantsInfo.participants)))

    }

    func handleParticipantsRemoved(dispatch: @escaping ChatActionDispatch,
                                   participantsInfo: ParticipantsInfoModel) {
        dispatch(.participantsAction(.participantsRemoved(participants: participantsInfo.participants)))
    }
}

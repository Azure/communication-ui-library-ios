//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Middleware {
    static func liveMessageRepositoryMiddleware(
        messageMiddlewareHandler actionHandler: MessageRepositoryMiddlewareHandling)
    -> Middleware<AppState> {
        Middleware<AppState>(
            apply: { _, _ in
                return { next in
                    return { action in
                        switch action {
                        case .chatAction(let chatAction):
                            handleChatMessageAction(chatAction, actionHandler)
                        case .participantsAction(let participantsAction):
                            handleParticipantsAction(participantsAction, actionHandler)
                        default:
                            break
                        }
                        return next(action)
                    }
                }
            }
        )
    }
}

private func handleChatMessageAction(
    _ action: ChatAction,
    _ actionHandler: MessageRepositoryMiddlewareHandling) {
        switch action {
        case .loadInitialMessagesSuccess(let messages):
            actionHandler.loadInitialMessage(messages: messages)
        case .fetchPreviousMessagesSuccess(let messages):
            actionHandler.fetchPreviousMessage(messages: messages)
        case .sendMessageTriggered(let message):
            actionHandler.sendMessage(message: message)
        case .sendMessageSuccess(let message):
            actionHandler.sendMessageSuccess(message: message)
        case .messageReceived(let message):
            actionHandler.messageReceived(message: message)
        case .messageEditReceived(let message):
            actionHandler.messageEditedReceived(message: message)
        case .messageDeleteReceived(let message):
            actionHandler.messageDeleteReceived(message: message)
        case .sendMessageRetry(let message):
            actionHandler.sendMessageRetry(message: message)
        case .topicUpdateReceived(let topic):
            actionHandler.topicUpdatedReceived(topic: topic)
        default:
            break
        }
    }

private func handleParticipantsAction(
    _ action: ParticipantsAction,
    _ actionHandler: MessageRepositoryMiddlewareHandling) {
        switch action {
        case .participantsAddedReceived(let participants):
            actionHandler.participantsAddedReceived(participants: participants)
        case .participantsRemovedReceived(let participants):
            actionHandler.participantsRemovedReceived(participants: participants)
        default:
            break
        }
    }

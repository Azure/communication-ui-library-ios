//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Middleware {
    static func liveRepositoryMiddleware(
        repositoryMiddlewareHandler actionHandler: RepositoryMiddlewareHandling)
    -> Middleware<AppState> {
        Middleware<AppState>(
            apply: { _, _ in
                return { next in
                    return { action in
                        switch action {
                        case .chatAction(let chatAction):
                            handleChatAction(chatAction, actionHandler)
                        case .participantsAction(let participantsAction):
                            handleParticipantsAction(participantsAction, actionHandler)
                        case .repositoryAction(let repositoryAction):
                            handleRepositoryAction(repositoryAction, actionHandler)
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

private func handleChatAction(
    _ action: ChatAction,
    _ actionHandler: RepositoryMiddlewareHandling) {
        print("`handleChatAction` not implemented")
    }

private func handleParticipantsAction(
    _ action: ParticipantsAction,
    _ actionHandler: RepositoryMiddlewareHandling) {
        print("`handleParticipantsAction` not implemented")
    }

private func handleRepositoryAction(
    _ action: RepositoryAction,
    _ actionHandler: RepositoryMiddlewareHandling) {
        switch action {
        case .fetchInitialMessagesSuccess(let messages):
            actionHandler.loadInitialMessages(messages: messages)
        case .chatMessageReceived(let message):
            actionHandler.addReceivedMessage(message: message)
        default:
            break
        }
    }

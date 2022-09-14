//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

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
        print("`handleChatMessageAction` not implemented")
    }

private func handleParticipantsAction(
    _ action: ParticipantsAction,
    _ actionHandler: MessageRepositoryMiddlewareHandling) {
        print("`handleParticipantsAction` not implemented")
    }

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Middleware {
    static func liveParticipantsMiddleware(
        participantsActionHandler actionHandler: ParticipantsActionHandling)
    -> Middleware<AppState> {
        Middleware<AppState>(
            apply: { dispatch, getState in
                return { next in
                    return { action in
                        switch action {
                        case .participantsAction(let participantsAction):
                            handleParticipantsAction(participantsAction, actionHandler, getState, dispatch)
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

private func handleParticipantsAction(_ action: ParticipantsAction,
                                      _ actionHandler: ParticipantsActionHandling,
                                      _ getState: () -> AppState,
                                      _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .sendReadReceiptTriggered(let messageId):
        actionHandler.sendReadReceipt(messageId: messageId, dispatch: dispatch)
    default:
        break
    }
}

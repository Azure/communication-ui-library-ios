//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Middleware {
    static func liveChatMiddleware(
        chatActionHandler actionHandler: ChatActionHandling,
        chatServiceListener serviceListener: ChatServiceListening)
    -> Middleware<AppState> {
        Middleware<AppState>(
            apply: { dispatch, getState in
                return { next in
                    return { action in
                        switch action {
                        case .lifecycleAction(let lifecycleAction):
                            handleLifecycleAction(lifecycleAction, actionHandler, getState, dispatch)
                        case .chatAction(let chatAction):
                            handleChatMessageAction(chatAction, actionHandler, serviceListener, getState, dispatch)
                        case .participantsAction(let participantsAction):
                            handleParticipantsAction(participantsAction, actionHandler, getState, dispatch)
                        case .errorAction(_),
                                .compositeExitAction,
                                .chatViewLaunched:
                            break
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

private func handleLifecycleAction(_ action: LifecycleAction,
                                   _ actionHandler: ChatActionHandling,
                                   _ getState: () -> AppState,
                                   _ dispatch: @escaping ActionDispatch) {
    print("`handleLifecycleAction` not implemented")
}

private func handleChatMessageAction(_ action: ChatAction,
                                     _ actionHandler: ChatActionHandling,
                                     _ serviceListener: ChatServiceListening,
                                     _ getState: () -> AppState,
                                     _ dispatch: @escaping ActionDispatch) {
    print("`handleChatMessageAction` not implemented")
}

private func handleParticipantsAction(_ action: ParticipantsAction,
                                      _ actionHandler: ChatActionHandling,
                                      _ getState: () -> AppState,
                                      _ dispatch: @escaping ActionDispatch) {
    print("`handleParticipantsAction` not implemented")
}

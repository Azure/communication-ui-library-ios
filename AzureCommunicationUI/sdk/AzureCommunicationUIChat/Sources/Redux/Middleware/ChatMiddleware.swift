//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Middleware {
    static func liveChatMiddleware(
        chatActionHandler actionHandler: ChatActionHandling,
        chatServiceEventHandler serviceEventHandler: ChatServiceEventHandling)
    -> Middleware<AppState> {
        Middleware<AppState>(
            apply: { dispatch, getState in
                return { next in
                    return { action in
                        switch action {
                        case .lifecycleAction(let lifecycleAction):
                            handleLifecycleAction(lifecycleAction, actionHandler, getState, dispatch)
                        case .chatAction(let chatAction):
                            handleChatAction(chatAction, actionHandler, serviceEventHandler, getState, dispatch)
                        case .participantsAction(let participantsAction):
                            handleParticipantsAction(participantsAction, actionHandler, getState, dispatch)
                        case .repositoryAction(let repositoryAction):
                            handleRepositoryAction(repositoryAction, actionHandler, getState, dispatch)
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

private func handleChatAction(_ action: ChatAction,
                              _ actionHandler: ChatActionHandling,
                              _ serviceListener: ChatServiceEventHandling,
                              _ getState: () -> AppState,
                              _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .initializeChatTriggered:
        actionHandler.initialize(state: getState(),
                                 dispatch: dispatch,
                                 serviceListener: serviceListener)
    case .sendTypingIndicatorTriggered:
       actionHandler.sendTypingIndicator(state: getState(),
                                         dispatch: dispatch)
    case .realTimeNotificationConnected:
        // stub: stop-pulling msg to be implemented for GA
        break
    case .realTimeNotificationDisconnected:
        // stub: pulling msg to be implemented for GA
        break
    case .chatThreadDeleted:
        actionHandler.onChatThreadDeleted(dispatch: dispatch)
    default:
        break
    }
}

private func handleParticipantsAction(_ action: ParticipantsAction,
                                      _ actionHandler: ChatActionHandling,
                                      _ getState: () -> AppState,
                                      _ dispatch: @escaping ActionDispatch) {
    print("`handleParticipantsAction` not implemented")
}

private func handleRepositoryAction(_ action: RepositoryAction,
                                    _ actionHandler: ChatActionHandling,
                                    _ getState: () -> AppState,
                                    _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .fetchInitialMessagesTriggered:
        actionHandler.getInitialMessages(state: getState(),
                                         dispatch: dispatch)
    case .fetchPreviousMessagesTriggered:
        actionHandler.getPreviousMessages(state: getState(),
                                          dispatch: dispatch)
    case .sendMessageTriggered(let internalId, let content):
        actionHandler.sendMessage(internalId: internalId,
                                  content: content,
                                  state: getState(),
                                  dispatch: dispatch)
    default:
        break
    }
}

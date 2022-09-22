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
    switch action {
    case .backgroundEntered:
        actionHandler.enterBackground(state: getState(), dispatch: dispatch)
    case .foregroundEntered:
        actionHandler.enterForeground(state: getState(), dispatch: dispatch)
    }
}

private func handleChatMessageAction(_ action: ChatAction,
                                     _ actionHandler: ChatActionHandling,
                                     _ serviceListener: ChatServiceListening,
                                     _ getState: () -> AppState,
                                     _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .chatStartRequested:
        actionHandler.chatStart(state: getState(),
                                dispatch: dispatch,
                                serviceListener: serviceListener)
    case .sendTypingIndicatorTriggered:
        actionHandler.sendTypingIndicator(state: getState(),
                                          dispatch: dispatch)
    case .sendReadReceiptTriggered(let messageId):
        actionHandler.sendMessageRead(messageId: messageId,
                                      state: getState(),
                                      dispatch: dispatch)
    case .sendMessageTriggered(let message):
        actionHandler.sendMessage(message: message,
                                  state: getState(),
                                  dispatch: dispatch)
    case .editMessageTriggered(let message):
        actionHandler.editMessage(message: message,
                                  state: getState(),
                                  dispatch: dispatch)
    case .deleteMessageTriggered(let messageId):
        actionHandler.deleteMessage(messageId: messageId,
                                      state: getState(),
                                      dispatch: dispatch)

    case .sendMessageRetry(let message):
        // does this need to be a new event?
        actionHandler.sendMessage(message: message,
                                  state: getState(),
                                  dispatch: dispatch)

    case .fetchPreviousMessagesTriggered:
        actionHandler.fetchPreviousMessages(state: getState(),
                                            dispatch: dispatch)
    default:
        break
    }
}

private func handleParticipantsAction(_ action: ParticipantsAction,
                                      _ actionHandler: ChatActionHandling,
                                      _ getState: () -> AppState,
                                      _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .retrieveParticipantsListTriggered:
        actionHandler.listParticipants(state: getState(),
                                       dispatch: dispatch)
    case .removeParticipantTriggered(let participant):
        actionHandler.removeParticipant(participant,
                                        state: getState(),
                                        dispatch: dispatch)
    case .leaveChatTriggered:
        actionHandler.removeLocalParticipant(state: getState(),
                                             dispatch: dispatch)
    default:
        break
    }
}

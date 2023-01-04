//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Middleware where State == ChatAppState {
    static func liveChatMiddleware(
        chatActionHandler actionHandler: ChatActionHandling,
        chatServiceEventHandler serviceEventHandler: ChatServiceEventHandling)
    -> Middleware<State, AzureCommunicationUIChat.Action> {
        .init(
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

    private static func handleLifecycleAction(_ action: LifecycleAction,
                                              _ actionHandler: ChatActionHandling,
                                              _ getState: () -> State,
                                              _ dispatch: @escaping ActionDispatch) {
        print("`handleLifecycleAction` not implemented")
    }

    private static func handleChatAction(_ action: ChatAction,
                                         _ actionHandler: ChatActionHandling,
                                         _ serviceListener: ChatServiceEventHandling,
                                         _ getState: () -> State,
                                         _ dispatch: @escaping ActionDispatch) {
        switch action {
        case .initializeChatTriggered:
            actionHandler.initialize(state: getState(),
                                     dispatch: dispatch,
                                     serviceListener: serviceListener)
        case .disconnectChatTriggered:
            actionHandler.disconnectChat(dispatch: dispatch)
        case .disconnectChatSuccess:
            break
        case .sendTypingIndicatorTriggered:
            actionHandler.sendTypingIndicator(state: getState(),
                                              dispatch: dispatch)
        case .realTimeNotificationConnected:
            // stub: recieved event that trouter has connected to backend services
            break
        case .realTimeNotificationDisconnected:
            // stub: network disconnected, trouter is unable to reach services
            break
        case .chatThreadDeleted:
            actionHandler.onChatThreadDeleted(dispatch: dispatch)
        default:
            break
        }
    }

    private static func handleParticipantsAction(_ action: ParticipantsAction,
                                                 _ actionHandler: ChatActionHandling,
                                                 _ getState: @escaping () -> State,
                                                 _ dispatch: @escaping ActionDispatch) {
        switch action {
        case .sendReadReceiptTriggered(let messageId):
            actionHandler.sendReadReceipt(messageId: messageId, state: getState(), dispatch: dispatch)
        case .typingIndicatorReceived(_):
            actionHandler.setTypingParticipantTimer(getState, dispatch)
        default:
            break
        }
    }

    private static func handleRepositoryAction(_ action: RepositoryAction,
                                               _ actionHandler: ChatActionHandling,
                                               _ getState: () -> State,
                                               _ dispatch: @escaping ActionDispatch) {
        switch action {
        case .fetchInitialMessagesTriggered:
            actionHandler.getInitialMessages(state: getState(),
                                             dispatch: dispatch)
            actionHandler.getListOfParticipants(state: getState(),
                                                dispatch: dispatch)
        case .fetchPreviousMessagesTriggered:
            actionHandler.getPreviousMessages(state: getState(),
                                              dispatch: dispatch)
        case .sendMessageTriggered(let internalId, let content):
            actionHandler.sendMessage(internalId: internalId,
                                      content: content,
                                      state: getState(),
                                      dispatch: dispatch)

        case .editMessageTriggered(let messageId, let content, let prevContent):
            actionHandler.editMessage(messageId: messageId,
                                      content: content,
                                      prevContent: prevContent,
                                      state: getState(),
                                      dispatch: dispatch)
        case .deleteMessageTriggered(let messageId):
            actionHandler.deleteMessage(messageId: messageId,
                                        state: getState(),
                                        dispatch: dispatch)
        default:
            break
        }
    }
}

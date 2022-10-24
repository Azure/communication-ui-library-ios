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
            apply: { dispatch, getState in
                return { next in
                    return { action in
                        switch action {
                        case .chatAction(let chatAction):
                            handleChatAction(chatAction, actionHandler, getState, dispatch)
                        case .repositoryAction(let repositoryAction):
                            handleRepositoryAction(repositoryAction, actionHandler, getState, dispatch)
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
    _ actionHandler: RepositoryMiddlewareHandling,
    _ getState: () -> AppState,
    _ dispatch: @escaping ActionDispatch) {
        switch action {
        case .chatTopicUpdated(let threadInfo):
            actionHandler.addTopicUpdatedMessage(threadInfo: threadInfo,
                                                 state: getState(),
                                                 dispatch: dispatch)

        default:
            break
        }
    }

private func handleRepositoryAction(
    _ action: RepositoryAction,
    _ actionHandler: RepositoryMiddlewareHandling,
    _ getState: () -> AppState,
    _ dispatch: @escaping ActionDispatch) {
        switch action {

            // MARK: local events

        case .fetchInitialMessagesSuccess(let messages):
            actionHandler.loadInitialMessages(messages: messages,
                                              state: getState(),
                                              dispatch: dispatch)
        case .fetchPreviousMessagesSuccess(let messages):
            actionHandler.addPreviousMessages(messages: messages,
                                              state: getState(),
                                              dispatch: dispatch)
        case .sendMessageTriggered(let internalId, let content):
            actionHandler.addNewSentMessage(internalId: internalId,
                                            content: content,
                                            state: getState(),
                                            dispatch: dispatch)
        case .sendMessageSuccess(let internalId, let actualId):
            actionHandler.updateSentMessageId(internalId: internalId,
                                              actualId: actualId,
                                              state: getState(),
                                              dispatch: dispatch)

            // MARK: receiving remote events

        case .chatMessageReceived(let message):
            actionHandler.addReceivedMessage(message: message,
                                             state: getState(),
                                             dispatch: dispatch)
        case .chatMessageEditedReceived(let message):
            actionHandler.updateReceivedEditedMessage(message: message,
                                             state: getState(),
                                             dispatch: dispatch)
        case .chatMessageDeletedReceived(let message):
            actionHandler.updateReceivedDeletedMessage(message: message,
                                             state: getState(),
                                             dispatch: dispatch)
        default:
            break
        }
    }

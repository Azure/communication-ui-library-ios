//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol ChatActionHandling {
    @discardableResult
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func initialize(state: AppState,
                    dispatch: @escaping ActionDispatch,
                    serviceListener: ChatServiceEventHandling) -> Task<Void, Never>
    @discardableResult
    func getInitialMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func sendMessage(internalId: String,
                     content: String,
                     state: AppState,
                     dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func sendReadReceipt(messageId: String, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
}

class ChatActionHandler: ChatActionHandling {
    private let chatService: ChatServiceProtocol
    private let logger: Logger

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    func initialize(state: AppState,
                    dispatch: @escaping ActionDispatch,
                    serviceListener: ChatServiceEventHandling) -> Task<Void, Never> {
        Task {
            do {
                try await chatService.initalize()
                serviceListener.subscription(dispatch: dispatch)
            } catch {
                // dispatch error if invalid token *not handled*
                dispatch(.chatAction(.initializeChatFailed(error: error)))
            }
        }
    }

    // MARK: LifeCycleHandler
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        // Pause UI update
        Task {
            print("ChatActionHandler `enterBackground` not implemented")
        }
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        // rehydrate UI based on latest state, move to last unread message
        Task {
            print("ChatActionHandler `enterForeground` not implemented")
        }
    }

    // MARK: Chat Handler

    // MARK: Participants Handler

    // MARK: Repository Handler
    func getInitialMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                let initialMessages = try await chatService.getInitialMessages()
                dispatch(.repositoryAction(.fetchInitialMessagesSuccess(messages: initialMessages)))
            } catch {
                // dispatch error *not handled*
                dispatch(.repositoryAction(.fetchInitialMessagesFailed(error: error)))
            }
        }
    }

    func sendMessage(internalId: String,
                     content: String,
                     state: AppState,
                     dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                guard let displayName = state.chatState.localUser?.displayName else {
                    return
                }
                let actualId = try await chatService.sendMessage(
                    content: content,
                    senderDisplayName: displayName)
                dispatch(.repositoryAction(.sendMessageSuccess(
                    internalId: internalId,
                    actualId: actualId)))
            } catch {
                // dispatch error *not handled*
                dispatch(.repositoryAction(.sendMessageFailed(error: error)))
            }
        }
    }

    func sendReadReceipt(messageId: String, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await chatService.sendReadReceipt(messageId: messageId)
                dispatch(.chatAction(.sendReadReceiptSuccess))
            } catch {
                logger.error("ChatActionHandler sendReadReceipt failed: \(error)")
                dispatch(.chatAction(.sendReadReceiptFailed(error: error)))
            }
        }
    }
}

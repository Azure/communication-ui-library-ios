//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol ChatActionHandling {
    // MARK: LifeCycleHandler
    @discardableResult
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    // MARK: ChatActionHandler
    @discardableResult
    func onChatThreadDeleted(dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    // MARK: Participants Handler

    // MARK: Repository Handler
    @discardableResult
    func initialize(state: AppState,
                    dispatch: @escaping ActionDispatch,
                    serviceListener: ChatServiceEventHandling) -> Task<Void, Never>
    @discardableResult
    func getInitialMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func getListOfParticipants(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func getPreviousMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func sendMessage(internalId: String,
                     content: String,
                     state: AppState,
                     dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func sendTypingIndicator(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func sendReadReceipt(messageId: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
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
    func sendTypingIndicator(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await chatService.sendTypingIndicator()
                dispatch(.chatAction(.sendTypingIndicatorSuccess))
            } catch {
                logger.error("ChatActionHandler sendTypingIndicator failed: \(error)")
                dispatch(.chatAction(.sendTypingIndicatorFailed(error: error)))
            }
        }
    }

    func onChatThreadDeleted(dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            // may be extracted to function in the future
            dispatch(.errorAction(.fatalErrorUpdated(internalError: .chatEvicted, error: nil)))
        }
    }

    // MARK: Participants Handler
    func sendReadReceipt(messageId: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard let lastReadReceiptSentTimestamp = state.chatState.lastReadReceiptSentTimestamp else {
                await sendReadReceiptToChatService(messageId: messageId, dispatch: dispatch)
                return
            }

            guard let messageTimestamp = messageId.convertEpochStringToTimestamp(),
                  messageTimestamp > lastReadReceiptSentTimestamp else {
                return
            }
            await sendReadReceiptToChatService(messageId: messageId, dispatch: dispatch)
        }
    }

    private func sendReadReceiptToChatService(messageId: String, dispatch: @escaping ActionDispatch) async {
        do {
            try await chatService.sendReadReceipt(messageId: messageId)
            dispatch(.participantsAction(.sendReadReceiptSuccess(messageId: messageId)))
        } catch {
            logger.error("ChatActionHandler sendReadReceipt failed: \(error)")
            dispatch(.participantsAction(.sendReadReceiptFailed(error: error as NSError)))
        }
    }

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

    func getListOfParticipants(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                let listOfParticipants = try await chatService.getListOfParticipants()
                dispatch(.participantsAction(.fetchListOfParticipantsSuccess(participants: listOfParticipants)))
            } catch {
                dispatch(.participantsAction(.fetchListOfParticipantsFailed(error: error)))
            }
        }
    }

    func getPreviousMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                let previousMessages = try await chatService.getPreviousMessages()
                if !previousMessages.isEmpty {
                    dispatch(.repositoryAction(.fetchPreviousMessagesSuccess(messages: previousMessages)))
                }
            } catch {
                // dispatch error *not handled*
                dispatch(.repositoryAction(.fetchPreviousMessagesFailed(error: error)))
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
}

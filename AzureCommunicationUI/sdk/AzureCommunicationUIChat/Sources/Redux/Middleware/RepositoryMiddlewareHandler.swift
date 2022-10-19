//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
@_spi(common) import AzureCommunicationUICommon
import Foundation

protocol RepositoryMiddlewareHandling {
    @discardableResult
    func loadInitialMessages(
        messages: [ChatMessageInfoModel],
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addNewSentMessage(
        internalId: String,
        content: String,
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateSentMessageId(
        internalId: String,
        actualId: String,
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never>

    @discardableResult
    func addReceivedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never>
}

class RepositoryMiddlewareHandler: RepositoryMiddlewareHandling {
    private let messageRepository: MessageRepositoryManagerProtocol
    private let logger: Logger

    init(messageRepository: MessageRepositoryManagerProtocol, logger: Logger) {
        self.messageRepository = messageRepository
        self.logger = logger
    }

    func loadInitialMessages(
        messages: [ChatMessageInfoModel],
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never> {
        Task {
            messageRepository.addInitialMessages(initialMessages: messages)
        }
    }

    func addNewSentMessage(
        internalId: String,
        content: String,
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never> {
        Task {
            guard let localUserId = state.chatState.localUser?.identifier.stringValue,
                  let displayName = state.chatState.localUser?.displayName else {
                return
            }
            let message = ChatMessageInfoModel(
                id: internalId,
                type: .text,
                senderId: localUserId,
                senderDisplayName: displayName,
                content: content)
            messageRepository.addNewSendingMessage(message: message)
            dispatch(.repositoryAction(.repositoryUpdated))
        }
    }

    func updateSentMessageId(
        internalId: String,
        actualId: String,
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never> {
        Task {
            messageRepository.replaceMessageId(internalId: internalId,
                                               actualId: actualId)
        }
    }

    func addReceivedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ChatActionDispatch) -> Task<Void, Never> {
        Task {
            messageRepository.addReceivedMessage(message: message)
        }
    }
}

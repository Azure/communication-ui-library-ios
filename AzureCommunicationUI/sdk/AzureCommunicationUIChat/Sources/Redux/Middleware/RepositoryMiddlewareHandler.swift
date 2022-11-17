//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import AzureCore
import Foundation

protocol RepositoryMiddlewareHandling {
    @discardableResult
    func loadInitialMessages(
        messages: [ChatMessageInfoModel],
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addPreviousMessages(
        messages: [ChatMessageInfoModel],
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addNewSentMessage(
        internalId: String,
        content: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateNewEditedMessage(
        messageId: String,
        content: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateNewDeletedMessage(
        messageId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateSentMessageId(
        internalId: String,
        actualId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateEditedMessageTimestamp(
        messageId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateDeletedMessageTimestamp(
        messageId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    @discardableResult
    func addTopicUpdatedMessage(
        threadInfo: ChatThreadInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func participantAddedMessage(participants: [ParticipantInfoModel],
                                 dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func participantRemovedMessage(participants: [ParticipantInfoModel],
                                   dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addReceivedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateReceivedEditedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateReceivedDeletedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
}

class RepositoryMiddlewareHandler: RepositoryMiddlewareHandling {
    private let messageRepository: MessageRepositoryManagerProtocol
    private let logger: Logger

    init(messageRepository: MessageRepositoryManagerProtocol,
         logger: Logger) {
        self.messageRepository = messageRepository
        self.logger = logger
    }

    func loadInitialMessages(
        messages: [ChatMessageInfoModel],
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.addInitialMessages(initialMessages: messages)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func addPreviousMessages(
        messages: [ChatMessageInfoModel],
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.addPreviousMessages(previousMessages: messages)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func addNewSentMessage(
        internalId: String,
        content: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
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

    func updateNewEditedMessage(
        messageId: String,
        content: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.editMessage(messageId: messageId, content: content)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateNewDeletedMessage(
        messageId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.deleteMessage(messageId: messageId)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateSentMessageId(
        internalId: String,
        actualId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.replaceMessageId(internalId: internalId,
                                                   actualId: actualId)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateEditedMessageTimestamp(
        messageId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateEditMessageTimestamp(messageId: messageId)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateDeletedMessageTimestamp(
        messageId: String,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateDeletedMessageTimestamp(messageId: messageId)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func addTopicUpdatedMessage(
        threadInfo: ChatThreadInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.addTopicUpdatedMessage(chatThreadInfo: threadInfo)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func participantAddedMessage(participants: [ParticipantInfoModel],
                                 dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            let message = ChatMessageInfoModel(type: .participantsAdded,
                                               createdOn: Iso8601Date(),
                                               participants: participants)
            messageRepository.addParticipantAdded(message: message)
            dispatch(.repositoryAction(.repositoryUpdated))
        }
    }

    func participantRemovedMessage(participants: [ParticipantInfoModel],
                                   dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            let message = ChatMessageInfoModel(type: .participantsRemoved,
                                               createdOn: Iso8601Date(),
                                               participants: participants)
            messageRepository.addParticipantRemoved(message: message)
            dispatch(.repositoryAction(.repositoryUpdated))
        }
    }

    func addReceivedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.addReceivedMessage(message: message)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateReceivedEditedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateMessageEdited(message: message)
            }
        }

    func updateReceivedDeletedMessage(
        message: ChatMessageInfoModel,
        state: AppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateMessageDeleted(message: message)
            }
        }
}

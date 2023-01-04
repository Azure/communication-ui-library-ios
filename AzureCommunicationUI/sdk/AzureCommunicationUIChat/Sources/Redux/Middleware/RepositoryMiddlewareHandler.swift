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
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addPreviousMessages(
        messages: [ChatMessageInfoModel],
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addNewSentMessage(
        internalId: String,
        content: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateNewEditedMessage(
        messageId: String,
        content: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateNewDeletedMessage(
        messageId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateSentMessageIdAndSendStatus(
        internalId: String,
        actualId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateEditedMessageTimestamp(
        messageId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateDeletedMessageTimestamp(
        messageId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    @discardableResult
    func addTopicUpdatedMessage(
        threadInfo: ChatThreadInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func participantAddedMessage(participants: [ParticipantInfoModel],
                                 state: ChatAppState,
                                 dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func participantRemovedMessage(participants: [ParticipantInfoModel],
                                   dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addLocalUserRemovedMessage(state: ChatAppState,
                                    dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func addReceivedMessage(
        message: ChatMessageInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateReceivedEditedMessage(
        message: ChatMessageInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateReceivedDeletedMessage(
        message: ChatMessageInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateMessageSendStatus(
        messageId: String,
        messageSendStatus: MessageSendStatus,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func updateMessageReceiptReceivedStatus(
        readReceiptInfo: ReadReceiptInfoModel,
        state: ChatAppState,
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
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                let filteredMessages = getMessagesWithoutMaskedParticipants(messages: messages, state: state)
                messageRepository.addInitialMessages(initialMessages: filteredMessages)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func addPreviousMessages(
        messages: [ChatMessageInfoModel],
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                let filteredMessages = getMessagesWithoutMaskedParticipants(messages: messages, state: state)
                messageRepository.addPreviousMessages(previousMessages: filteredMessages)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func addNewSentMessage(
        internalId: String,
        content: String,
        state: ChatAppState,
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
                    content: content,
                    sendStatus: .sending,
                    isLocalUser: true)
                messageRepository.addNewSendingMessage(message: message)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateNewEditedMessage(
        messageId: String,
        content: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.editMessage(messageId: messageId, content: content)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateNewDeletedMessage(
        messageId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.deleteMessage(messageId: messageId)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateSentMessageIdAndSendStatus(
        internalId: String,
        actualId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.replaceMessageId(internalId: internalId,
                                                   actualId: actualId)
                messageRepository.updateMessageSendStatus(messageId: actualId, messageSendStatus: .sent)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateEditedMessageTimestamp(
        messageId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateEditMessageTimestamp(messageId: messageId)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateDeletedMessageTimestamp(
        messageId: String,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateDeletedMessageTimestamp(messageId: messageId)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func addTopicUpdatedMessage(
        threadInfo: ChatThreadInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.addTopicUpdatedMessage(chatThreadInfo: threadInfo)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func addLocalUserRemovedMessage(state: ChatAppState,
                                    dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            messageRepository.addLocalUserRemovedMessage()
            dispatch(.repositoryAction(.repositoryUpdated))
        }
    }

    func participantAddedMessage(participants: [ParticipantInfoModel],
                                 state: ChatAppState,
                                 dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            let filteredParticipants = filterOutMaskedParticipantsFromMessage(participants: participants, state: state)
            guard !filteredParticipants.isEmpty else {
                return
            }
            let message = ChatMessageInfoModel(
                type: .participantsAdded,
                createdOn: Iso8601Date(),
                participants: filteredParticipants)
            messageRepository.addParticipantAdded(message: message)
            dispatch(.repositoryAction(.repositoryUpdated))
        }
    }

    func participantRemovedMessage(participants: [ParticipantInfoModel],
                                   dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            let message = ChatMessageInfoModel(
                type: .participantsRemoved,
                createdOn: Iso8601Date(),
                participants: participants)
            messageRepository.addParticipantRemoved(message: message)
            dispatch(.repositoryAction(.repositoryUpdated))
        }
    }

    func addReceivedMessage(
        message: ChatMessageInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.addReceivedMessage(message: message)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateReceivedEditedMessage(
        message: ChatMessageInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateMessageEdited(message: message)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateReceivedDeletedMessage(
        message: ChatMessageInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateMessageDeleted(message: message)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateMessageSendStatus(
        messageId: String,
        messageSendStatus: MessageSendStatus,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateMessageSendStatus(messageId: messageId, messageSendStatus: messageSendStatus)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    func updateMessageReceiptReceivedStatus(
        readReceiptInfo: ReadReceiptInfoModel,
        state: ChatAppState,
        dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                messageRepository.updateMessageReadReceiptStatus(readReceiptInfo: readReceiptInfo, state: state)
                dispatch(.repositoryAction(.repositoryUpdated))
            }
        }

    private func getMessagesWithoutMaskedParticipants(
        messages: [ChatMessageInfoModel],
        state: ChatAppState) -> [ChatMessageInfoModel] {
            var newMessages = messages
            var messageIdsToRemove: Set<String> = []
            for (index, message) in messages.enumerated() where message.type == .participantsAdded {
                let filteredParticipants = filterOutMaskedParticipantsFromMessage(
                    participants: message.participants,
                    state: state)
                guard !filteredParticipants.isEmpty else {
                    messageIdsToRemove.insert(message.id)
                    continue
                }
                var newMessage = message
                newMessage.participants = filteredParticipants
                newMessages[index] = newMessage
            }
            newMessages = newMessages.filter {
                !messageIdsToRemove.contains($0.id)
            }
            return newMessages
        }

    private func filterOutMaskedParticipantsFromMessage(
        participants: [ParticipantInfoModel],
        state: ChatAppState) -> [ParticipantInfoModel] {
            let maskedParticipants = state.participantsState.maskedParticipants
            let participants = participants.filter {
                !maskedParticipants.contains($0.id)
            }
            return participants
        }
}

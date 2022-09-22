//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import AzureCommunicationCommon

protocol ChatActionHandling {
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch)
    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch)

    func chatStart(state: AppState, dispatch: @escaping ActionDispatch, serviceListener: ChatServiceListening)
    func sendTypingIndicator(state: AppState, dispatch: @escaping ActionDispatch)
    func sendMessageRead(messageId: String, state: AppState, dispatch: @escaping ActionDispatch)
    func sendMessage(message: ChatMessageInfoModel, state: AppState, dispatch: @escaping ActionDispatch)
    func editMessage(message: ChatMessageInfoModel, state: AppState, dispatch: @escaping ActionDispatch)
    func deleteMessage(messageId: String, state: AppState, dispatch: @escaping ActionDispatch)
    func fetchPreviousMessages(state: AppState, dispatch: @escaping ActionDispatch)

    func listParticipants(state: AppState, dispatch: @escaping ActionDispatch)
    func removeParticipant(_ participant: ParticipantInfoModel, state: AppState, dispatch: @escaping ActionDispatch)
    func removeLocalParticipant(state: AppState, dispatch: @escaping ActionDispatch)
}

class ChatActionHandler: ChatActionHandling {
    private let chatService: ChatServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    func chatStart(state: AppState, dispatch: @escaping ActionDispatch, serviceListener: ChatServiceListening) {
        chatService.chatStart()
            .map {
                ChatAction.loadInitialMessagesSuccess(messages: $0)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler sendMessage failed")
                    dispatch(.chatAction(.sendMessageFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: {
                // when to start listenting to events? moved to middleware?
                serviceListener.subscription(dispatch: dispatch)
                dispatch(.chatAction($0))
            })
            .store(in: cancelBag)
    }

    // MARK: LifeCycleHandler
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) {
        // Pause UI update
        print("ChatActionHandler `enterBackground` not implemented")
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) {
        // rehydrate UI based on latest state, move to last unread message
        print("ChatActionHandler `enterForeground` not implemented")
    }

    // MARK: Chat Handler
    func sendTypingIndicator(state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.sendTypingIndicator()
            .map {
                ChatAction.sendTypingIndicatorSuccess
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler sendTypingIndicator failed")
                    dispatch(.chatAction(.sendTypingIndicatorFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newChatAction in
                dispatch(.chatAction(newChatAction))
            })
            .store(in: cancelBag)
    }

    func sendMessageRead(messageId: String, state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.sendMessageRead(messageId: messageId)
            .map {
                ChatAction.sendReadReceiptSuccess
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler sendMessageRead failed")
                    dispatch(.chatAction(.sendReadReceiptFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newChatAction in
                dispatch(.chatAction(newChatAction))
            })
            .store(in: cancelBag)
    }

    func sendMessage(message: ChatMessageInfoModel, state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.sendMessage(message: message)
            .map {
                var newMessage = message
                newMessage.replaceDummyId(realMessageId: $0)
                return ChatAction.sendMessageSuccess(message: newMessage)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler sendMessage failed")
                    dispatch(.chatAction(.sendMessageFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newChatAction in
                dispatch(.chatAction(newChatAction))
            })
            .store(in: cancelBag)
    }

    func editMessage(message: ChatMessageInfoModel, state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.editMessage(message: message)
            .map {
                ChatAction.editMessageSuccess
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler editMessage failed")
                    dispatch(.chatAction(.editMessageFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newChatAction in
                dispatch(.chatAction(newChatAction))
            })
            .store(in: cancelBag)
    }

    func deleteMessage(messageId: String, state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.deleteMessage(messageId: messageId)
            .map {
                ChatAction.deleteMessageSuccess
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler deleteMessage failed")
                    dispatch(.chatAction(.deleteMessageFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newChatAction in
                dispatch(.chatAction(newChatAction))
            })
            .store(in: cancelBag)
    }

    func fetchPreviousMessages(state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.fetchPreviousMessages()
            .map {
                ChatAction.fetchPreviousMessagesSuccess(messages: $0)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler fetchPreviousMessages failed")
                    dispatch(.chatAction(.fetchPreviousMessagessFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newChatAction in
                dispatch(.chatAction(newChatAction))
            })
            .store(in: cancelBag)
    }

    // MARK: Participants Handler
    func listParticipants(state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.listParticipants()
            .map {
                ParticipantsAction.retrieveParticipantsListSuccess(participants: $0)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler listParticipants failed")
                    dispatch(.participantsAction(.removeParticipantFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newParticipantAction in
                dispatch(.participantsAction(newParticipantAction))
            })
            .store(in: cancelBag)
    }

    func removeParticipant(_ participant: ParticipantInfoModel, state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.removeParticipant(participant: participant)
            .map {
                ParticipantsAction.removeParticipantSuccess
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler removeParticipant failed")
                    dispatch(.participantsAction(.removeParticipantFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newParticipantAction in
                dispatch(.participantsAction(newParticipantAction))
            })
            .store(in: cancelBag)
    }

    func removeLocalParticipant(state: AppState, dispatch: @escaping ActionDispatch) {
        chatService.removeLocalParticipant()
            .map {
                ParticipantsAction.leaveChatSuccess
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler removeParticipant failed")
                    dispatch(.participantsAction(.leaveChatFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newParticipantAction in
                dispatch(.participantsAction(newParticipantAction))
            })
            .store(in: cancelBag)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class ChatActionHandlerMocking: ChatActionHandling {

    var enterBackgroundCalled: ((Bool) -> Void)?
    var enterForegroundCalled: ((Bool) -> Void)?
    var onChatThreadDeletedCalled: ((Bool) -> Void)?
    var initializeCalled: ((Bool) -> Void)?
    var disconnectChatCalled: ((Bool) -> Void)?
    var getInitialMessagesCalled: ((Bool) -> Void)?
    var getListOfParticipantsCalled: ((Bool) -> Void)?
    var getPreviousMessagesCalled: ((Bool) -> Void)?
    var sendMessageCalled: ((Bool) -> Void)?
    var editMessageCalled: ((Bool) -> Void)?
    var deleteMessageCalled: ((Bool) -> Void)?
    var sendTypingIndicatorCalled: ((Bool) -> Void)?
    var setTypingIndicatorTimeoutCalled: ((Bool) -> Void)?
    var sendReadReceiptCalled: ((Bool) -> Void)?
    var sendReadReceiptSuccessCalled: ((Bool) -> Void)?

    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            enterBackgroundCalled?(true)
        }
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            enterForegroundCalled?(true)
        }
    }

    func onChatThreadDeleted(dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            onChatThreadDeletedCalled?(true)
        }
    }

    func initialize(state: AppState, dispatch: @escaping ActionDispatch, serviceListener: ChatServiceEventHandling) -> Task<Void, Never> {
        Task {
            initializeCalled?(true)
        }
    }

    func disconnectChat(dispatch: @escaping AzureCommunicationUIChat.ActionDispatch) -> Task<Void, Never> {
        Task {
            disconnectChatCalled?(true)
        }
    }

    func getInitialMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            getInitialMessagesCalled?(true)
        }
    }

    func getListOfParticipants(state: AzureCommunicationUIChat.AppState, dispatch: @escaping AzureCommunicationUIChat.ActionDispatch) -> Task<Void, Never> {
        Task {
            getListOfParticipantsCalled?(true)
        }
    }

    func getPreviousMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            getPreviousMessagesCalled?(true)
        }
    }

    func sendMessage(internalId: String, content: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            sendMessageCalled?(true)
        }
    }

    func editMessage(messageId: String, content: String, prevContent: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            editMessageCalled?(true)
        }
    }

    func deleteMessage(messageId: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            deleteMessageCalled?(true)
        }
    }

    func sendTypingIndicator(state: AzureCommunicationUIChat.AppState,
                             dispatch: @escaping AzureCommunicationUIChat.ActionDispatch) -> Task<Void, Never> {
        Task {
            sendTypingIndicatorCalled?(true)
        }
    }

    func setTypingParticipantTimer(_ getState: @escaping () -> AzureCommunicationUIChat.AppState,
                                   _ dispatch: @escaping AzureCommunicationUIChat.ActionDispatch) {
        Task {
            setTypingIndicatorTimeoutCalled?(true)
        }
    }

    func sendReadReceipt(
              messageId: String,
              state: AzureCommunicationUIChat.AppState,
              dispatch: @escaping AzureCommunicationUIChat.ActionDispatch) -> Task<Void, Never> {
        Task {
            sendReadReceiptCalled?(true)
        }
    }

    func sendReadReceiptSuccess(messageId: String, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            sendReadReceiptSuccessCalled?(true)
        }
    }
}

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
    var getInitialMessagesCalled: ((Bool) -> Void)?
    var sendMessageCalled: ((Bool) -> Void)?

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

    func getInitialMessages(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            getInitialMessagesCalled?(true)
        }
    }

    func sendMessage(internalId: String, content: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            sendMessageCalled?(true)
        }
    }
}

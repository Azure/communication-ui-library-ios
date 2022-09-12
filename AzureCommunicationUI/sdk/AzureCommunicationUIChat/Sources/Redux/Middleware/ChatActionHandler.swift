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
            .map { _ in
                // Stub action
                ChatAction.chatStartRequested
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("middlewareHandler failed: \(error)")
                case .finished:
                    print("middlewareHandler finished")
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

    // MARK: Participants Handler
}

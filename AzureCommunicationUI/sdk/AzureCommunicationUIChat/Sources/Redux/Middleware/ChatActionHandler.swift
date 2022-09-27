//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol ChatActionHandling {
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch)
    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch)

    func initialize(state: AppState,
                    dispatch: @escaping ActionDispatch,
                    serviceListener: ChatServiceEventHandling) -> Task<Void, Never>
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
                let initialMessages = try await chatService.getInitialMessages()
            } catch {
                print("ChatActionHandler `initialize` catch not implemented")
            }
        }
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

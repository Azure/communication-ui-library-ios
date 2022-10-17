//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

protocol CompositeViewModelFactoryProtocol {
    // MARK: CompositeViewModels
    func getChatViewModel() -> ChatViewModel

    // MARK: ComponentViewModels

    // MARK: ChatViewModels
    func makeTopBarViewModel(participantsState: ParticipantsState) -> TopBarViewModel
    func makeThreadViewModel() -> ThreadViewModel
    func makeMessageInputViewModel(dispatch: @escaping ActionDispatch) -> MessageInputViewModel
    func makeTypingParticipantsViewModel() -> TypingParticipantsViewModel
}

class CompositeViewModelFactory: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let store: Store<AppState>

    private weak var chatViewModel: ChatViewModel?

    // unit test needed
    // - only skeleton code to show view, class not finalized yet
    init(logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         messageRepositoryManager: MessageRepositoryManagerProtocol,
         store: Store<AppState>) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.messageRepositoryManager = messageRepositoryManager
        self.store = store
    }

    // MARK: CompositeViewModels
    func getChatViewModel() -> ChatViewModel {
        guard let viewModel = self.chatViewModel else {
            let viewModel = ChatViewModel(compositeViewModelFactory: self,
                                          logger: logger,
                                          store: store)
            self.chatViewModel = viewModel
            return viewModel
        }
        return viewModel
    }

    // MARK: ComponentViewModels

    // MARK: ChatViewModels
    func makeTopBarViewModel(participantsState: ParticipantsState) -> TopBarViewModel {
        TopBarViewModel(localizationProvider: localizationProvider,
                        participantsState: participantsState)
    }

    func makeThreadViewModel() -> ThreadViewModel {
        ThreadViewModel(messageRepositoryManager: messageRepositoryManager,
                        logger: logger)
    }

    func makeMessageInputViewModel(dispatch: @escaping ActionDispatch) -> MessageInputViewModel {
        MessageInputViewModel(logger: logger,
                              dispatch: dispatch)
    }

    func makeTypingParticipantsViewModel() -> TypingParticipantsViewModel {
        TypingParticipantsViewModel(logger: logger,
                                    localizationProvider: localizationProvider)
    }
}

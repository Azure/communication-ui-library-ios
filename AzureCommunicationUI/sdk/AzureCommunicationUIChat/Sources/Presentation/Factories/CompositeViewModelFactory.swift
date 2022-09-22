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
    func makeThreadViewModel(dispatch: @escaping ActionDispatch,
                             localUser: LocalUserInfoModel) -> ThreadViewModel
    func makeMessageViewModel(message: ChatMessageInfoModel,
                              index: Int,
                              messages: [ChatMessageInfoModel],
                              dispatch: @escaping ActionDispatch,
                              localUser: LocalUserInfoModel) -> MessageViewModel
    func makeMessageInputViewModel(dispatch: @escaping ActionDispatch,
                                   localUser: LocalUserInfoModel) -> MessageInputViewModel
    func makeTypingParticipantsViewModel() -> TypingParticipantsViewModel
}

class CompositeViewModelFactory: CompositeViewModelFactoryProtocol {
    private let messageRepository: MessageRepositoryManagerProtocol
    private let logger: Logger
    private let store: Store<AppState>
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol

    private weak var chatViewModel: ChatViewModel?

    init(messageRepository: MessageRepositoryManagerProtocol,
         logger: Logger,
         store: Store<AppState>,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol) {
        self.messageRepository = messageRepository
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
    }

    // MARK: CompositeViewModels
    func getChatViewModel() -> ChatViewModel {
        guard let viewModel = self.chatViewModel else {
            let viewModel = ChatViewModel(compositeViewModelFactory: self,
                                          logger: logger,
                                          store: store,
                                          localizationProvider: localizationProvider,
                                          accessibilityProvider: accessibilityProvider,
                                          isIpadInterface: UIDevice.current.userInterfaceIdiom == .pad)
            self.chatViewModel = viewModel
            return viewModel
        }
        return viewModel
    }

    // MARK: ComponentViewModels

    // MARK: ChatViewModels
    func makeThreadViewModel(dispatch: @escaping ActionDispatch,
                             localUser: LocalUserInfoModel) -> ThreadViewModel {
        ThreadViewModel(logger: logger,
                        compositeViewModelFactory: self,
                        messageRepository: messageRepository,
                        dispatch: dispatch,
                        localUser: localUser)
    }

    func makeMessageViewModel(message: ChatMessageInfoModel,
                              index: Int,
                              messages: [ChatMessageInfoModel],
                              dispatch: @escaping ActionDispatch,
                              localUser: LocalUserInfoModel) -> MessageViewModel {
        MessageViewModel(logger: logger,
                         message: message,
                         index: index,
                         messages: messages,
                         dispatch: dispatch,
                         localUser: localUser)
    }

    func makeMessageInputViewModel(dispatch: @escaping ActionDispatch,
                                   localUser: LocalUserInfoModel) -> MessageInputViewModel {
        MessageInputViewModel(logger: logger,
                              dispatch: dispatch,
                              localUser: localUser)
    }

    func makeTypingParticipantsViewModel() -> TypingParticipantsViewModel {
        TypingParticipantsViewModel(logger: logger)
    }
}

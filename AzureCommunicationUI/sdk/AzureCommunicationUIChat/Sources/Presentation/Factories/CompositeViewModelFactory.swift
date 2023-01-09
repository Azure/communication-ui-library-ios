//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CompositeViewModelFactoryProtocol {
    // MARK: CompositeViewModels
    func getChatViewModel() -> ChatViewModel

    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel

    // MARK: ChatViewModels
    func makeTopBarViewModel(dispatch: @escaping ActionDispatch,
                             participantsState: ParticipantsState) -> TopBarViewModel
    func makeMessageListViewModel(dispatch: @escaping ActionDispatch) -> MessageListViewModel
    func makeBottomBarViewModel(dispatch: @escaping ActionDispatch) -> BottomBarViewModel
    func makeTypingParticipantsViewModel() -> TypingParticipantsViewModel
}

class CompositeViewModelFactory: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let store: Store<ChatAppState, Action>

    private weak var chatViewModel: ChatViewModel?

    // unit test needed
    // - only skeleton code to show view, class not finalized yet
    init(logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         messageRepositoryManager: MessageRepositoryManagerProtocol,
         store: Store<ChatAppState, Action>) {
        self.logger = logger
        self.localizationProvider = localizationProvider
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
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType = .controlButton,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel {
        IconButtonViewModel(iconName: iconName,
                            buttonType: buttonType,
                            isDisabled: isDisabled,
                            action: action)
    }

    // MARK: ChatViewModels
    func makeTopBarViewModel(dispatch: @escaping ActionDispatch,
                             participantsState: ParticipantsState) -> TopBarViewModel {
        TopBarViewModel(compositeViewModelFactory: self,
                        localizationProvider: localizationProvider,
                        dispatch: dispatch,
                        participantsState: participantsState)
    }

    func makeMessageListViewModel(dispatch: @escaping ActionDispatch) -> MessageListViewModel {
        MessageListViewModel(compositeViewModelFactory: self,
                             messageRepositoryManager: messageRepositoryManager,
                             logger: logger,
                             dispatch: store.dispatch)
    }

    func makeBottomBarViewModel(dispatch: @escaping ActionDispatch) -> BottomBarViewModel {
        BottomBarViewModel(compositeViewModelFactory: self,
                           logger: logger,
                           dispatch: dispatch)
    }

    func makeTypingParticipantsViewModel() -> TypingParticipantsViewModel {
        TypingParticipantsViewModel(logger: logger,
                                    localizationProvider: localizationProvider)
    }
}

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
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel

    // MARK: ChatViewModels
    func makeTopBarViewModel(dispatch: @escaping ActionDispatch,
                             participantsState: ParticipantsState) -> TopBarViewModel
    func makeMessageListViewModel() -> MessageListViewModel
    func makeBottomBarViewModel(dispatch: @escaping ActionDispatch) -> BottomBarViewModel
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

    func makeMessageListViewModel() -> MessageListViewModel {
        MessageListViewModel(messageRepositoryManager: messageRepositoryManager,
                             logger: logger)
    }

    func makeBottomBarViewModel(dispatch: @escaping ActionDispatch) -> BottomBarViewModel {
        BottomBarViewModel(logger: logger,
                           dispatch: dispatch)
    }
}

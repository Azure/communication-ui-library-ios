//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

protocol CompositeViewModelFactoryProtocol {
    // MARK: CompositeViewModels
    @discardableResult
    func getChatViewModel() -> ChatViewModel

    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel

    // MARK: ChatViewModels
    func makeTopBarViewModel(dispatch: @escaping ActionDispatch,
                             participantsState: ParticipantsState) -> TopBarViewModel
    func makeMessageListViewModel(dispatch: @escaping ActionDispatch,
                                  chatState: ChatState) -> MessageListViewModel
    func makeBottomBarViewModel(dispatch: @escaping ActionDispatch) -> BottomBarViewModel
    func makeTypingParticipantsViewModel() -> TypingParticipantsViewModel
    func handleAppStatusChange(_ status: AppStatus)
    func destroyChatViewModel()
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

    func makeMessageListViewModel(dispatch: @escaping ActionDispatch,
                                  chatState: ChatState) -> MessageListViewModel {
        MessageListViewModel(messageRepositoryManager: messageRepositoryManager,
                             logger: logger,
                             dispatch: dispatch,
                             chatState: chatState)
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

    // MARK: View Model Life Cycle Handling
    func destroyChatViewModel() {
        chatViewModel = nil
    }

    func handleAppStatusChange(_ status: AppStatus) {
        store.dispatch(action: .lifecycleAction(status == .background ?
            .backgroundEntered : .foregroundEntered))
    }
}

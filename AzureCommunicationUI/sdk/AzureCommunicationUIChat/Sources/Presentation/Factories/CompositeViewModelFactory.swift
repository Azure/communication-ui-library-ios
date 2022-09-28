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
}

class CompositeViewModelFactory: CompositeViewModelFactoryProtocol {
    private let messageRepository: MessageRepositoryManagerProtocol
    private let logger: Logger
    private let store: Store<AppState>
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol

    private weak var chatViewModel: ChatViewModel?

    // Unit test needed
    // - only skeleton code to show view, class not finalized yet
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
        return ChatViewModel()
    }

    // MARK: ComponentViewModels

    // MARK: ChatViewModels
}

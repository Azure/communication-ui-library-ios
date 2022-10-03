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
    private let logger: Logger

    private weak var setupViewModel: SetupViewModel?

    // unit test needed
    // - only skeleton code to show view, class not finalized yet
    init(logger: Logger) {
        self.logger = logger
    }

    // MARK: CompositeViewModels
    func getChatViewModel() -> ChatViewModel {
        guard let viewModel = self.setupViewModel else {
            let viewModel = SetupViewModel(compositeViewModelFactory: self,
                                           logger: logger,
                                           store: store,
                                           networkManager: networkManager,
                                           localizationProvider: localizationProvider,
                                           navigationBarViewData: localOptions?.navigationBarViewData)
            self.setupViewModel = viewModel
            self.callingViewModel = nil
            return viewModel
        }
        return viewModel
        return ChatViewModel(
            compositeViewModelFactory: compositeViewModelFactory,
            logger: logger)
    }

    // MARK: ComponentViewModels

    // MARK: ChatViewModels
}

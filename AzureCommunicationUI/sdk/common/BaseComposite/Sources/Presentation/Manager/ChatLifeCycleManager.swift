//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

protocol LifeCycleManagerProtocol {}

class ChatLifeCycleManager: LifeCycleManagerProtocol {

    private let logger: Logger
    private let store: Store<AppState>
    private let viewModelFactory: CompositeViewModelFactoryProtocol

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         logger: Logger,
         viewModelFactory: CompositeViewModelFactoryProtocol) {
        self.logger = logger
        self.store = store
        self.viewModelFactory = viewModelFactory
        store.$state
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        switch state.lifeCycleState.currentStatus {
        case .background:
            enterBackground()
        case .foreground:
            enterForeground()
        }
    }

    func enterBackground() {
        logger.debug("Composite enters background mode")
        viewModelFactory.destroyChatViewModel()
    }

    func enterForeground() {
        logger.debug("Composite enters foreground mode")
        viewModelFactory.getChatViewModel()
    }
}

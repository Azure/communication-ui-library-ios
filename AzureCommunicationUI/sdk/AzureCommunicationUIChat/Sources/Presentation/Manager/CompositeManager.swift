//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol CompositeManagerProtocol {
    func start()
    func stop(completionHandler: @escaping (() -> Void))
}

class CompositeManager: CompositeManagerProtocol {
    private let logger: Logger
    private let store: Store<AppState>

    private var cancellables = Set<AnyCancellable>()
    private var compositeCompletionHandler: (() -> Void)?

    init(store: Store<AppState>,
         logger: Logger) {
        self.logger = logger
        self.store = store
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    func receive(_ state: AppState) {
        switch state.navigationState.status {
        case .inChat, .headless:
            break
        case .exit:
            compositeCompletionHandler?()
        }
    }

    func start() {
        store.dispatch(action: .chatAction(.chatStartRequested))
    }

    func stop(completionHandler: @escaping (() -> Void)) {
        store.dispatch(action: .compositeExitAction)
        compositeCompletionHandler = completionHandler
    }
}

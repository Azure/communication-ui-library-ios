//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import Combine

protocol LifeCycleManagerProtocol {}

class UIKitAppLifeCycleManager: LifeCycleManagerProtocol {

    private let logger: Logger
    private let store: Store<AppState>
    private let viewModelFactory: CompositeViewModelFactoryProtocol
    private var state = LifeCycleState()
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         logger: Logger,
         viewModelFactory: CompositeViewModelFactoryProtocol) {
        self.logger = logger
        self.store = store
        self.viewModelFactory = viewModelFactory
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willDeactivate),
                                               name: UIScene.willDeactivateNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didActivate),
                                               name: UIScene.didActivateNotification,
                                               object: nil)
    }

    private func receive(_ appState: AppState) {
        let newState = appState.lifeCycleState
        guard newState.currentStatus != state.currentStatus else {
            return
        }
        state = newState
        if state.currentStatus == .foreground {
            viewModelFactory.getChatViewModel()
        } else if state.currentStatus == .background {
            viewModelFactory.destroyChatViewModel()
        }
    }

    @objc func willDeactivate(_ notification: Notification) {
        logger.debug("Will Deactivate")
        store.dispatch(action: .lifecycleAction(.backgroundEntered))
    }

    @objc func didActivate(_ notification: Notification) {
        logger.debug("Did Activate")
        store.dispatch(action: .lifecycleAction(.foregroundEntered))
    }
}

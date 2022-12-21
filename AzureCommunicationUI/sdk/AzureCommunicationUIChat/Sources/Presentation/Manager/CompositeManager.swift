//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CompositeManagerProtocol {
    func start()
    func stop(completionHandler: @escaping ((Result<Void, ChatCompositeError>) -> Void))
}

class CompositeManager: CompositeManagerProtocol {
    private let logger: Logger
    private let store: Store<AppState>

    var cancellables = Set<AnyCancellable>()
    private var compositeCompletionHandler: [((Result<Void, ChatCompositeError>) -> Void)] = []

    init(store: Store<AppState>,
         logger: Logger) {
        self.logger = logger
        self.store = store
        self.store.$state.receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        let chatState = state.chatState
        if !chatState.isRealTimeNotificationConnected {
            for handler in compositeCompletionHandler {
                handler(.success(Void()))
            }
        }
    }

    func start() {
        store.dispatch(action: .chatAction(.initializeChatTriggered))
    }

    func stop(completionHandler: @escaping ((Result<Void, ChatCompositeError>) -> Void)) {
        store.dispatch(action: .chatAction(.disconnectChatTriggered))
        compositeCompletionHandler.append(completionHandler)
    }
}

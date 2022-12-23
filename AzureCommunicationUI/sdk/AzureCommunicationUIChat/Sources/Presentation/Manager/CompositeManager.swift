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
    private var compositeCompletionHandlers: [((Result<Void, ChatCompositeError>) -> Void)] = []

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
        let errorState = state.errorState
        if !chatState.isRealTimeNotificationConnected {
            if errorState.errorCategory == .trouter {
                onErrorDisconnecting(errorState: errorState)
            } else {
                onSuccessDisconnecting()
            }
        }
    }

    private func onErrorDisconnecting(errorState: ErrorState) {
        let error = ChatCompositeError(code: ChatCompositeErrorCode.disconnectFailed, error: errorState.error)
        for handler in compositeCompletionHandlers {
            handler(.failure(error))
        }
        compositeCompletionHandlers.removeAll()
    }

    private func onSuccessDisconnecting() {
        for handler in compositeCompletionHandlers {
            handler(.success(Void()))
        }
        compositeCompletionHandlers.removeAll()
    }

    func start() {
        store.dispatch(action: .chatAction(.initializeChatTriggered))
    }

    func stop(completionHandler: @escaping ((Result<Void, ChatCompositeError>) -> Void)) {
        store.dispatch(action: .chatAction(.disconnectChatTriggered))
        compositeCompletionHandlers.append(completionHandler)
    }
}

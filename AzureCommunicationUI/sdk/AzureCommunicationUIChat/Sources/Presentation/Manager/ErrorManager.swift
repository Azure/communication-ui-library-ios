//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ErrorManagerProtocol {
}

class ErrorManager: ErrorManagerProtocol {
    private let store: Store<ChatAppState, Action>
    private let eventsHandler: ChatAdapter.Events
    private var previousError: ChatCompositeInternalError?

    var cancellables = Set<AnyCancellable>()

    init(store: Store<ChatAppState, Action>,
         chatCompositeEventsHandler: ChatAdapter.Events) {
        self.store = store
        self.eventsHandler = chatCompositeEventsHandler
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: ChatAppState) {
        let errorState = state.errorState
        guard previousError != errorState.internalError else {
            return
        }
        previousError = errorState.internalError
        updateEventHandler(state.errorState)
        updateFatalError(state.errorState)
    }

    private func updateEventHandler(_ errorState: ErrorState) {
        guard let didFail = eventsHandler.onError,
              let compositeError = getChatCompositeError(errorState: errorState) else {
            return
        }
        didFail(compositeError)
    }

    private func updateFatalError(_ errorState: ErrorState) {
        guard let internalError = errorState.internalError,
              errorState.errorCategory == .fatal,
              internalError.isFatalError() else {
            return
        }
        // might require alert for accessiblity before exit
        print("For testing: compositeExitAction error \(internalError.rawValue)")
        store.dispatch(action: .compositeExitAction)
    }

    private func getChatCompositeError(errorState: ErrorState) -> ChatCompositeError? {
        guard let internalError = errorState.internalError,
              let errorCode = internalError.toChatCompositeErrorCode() else {
            return nil
        }

        return ChatCompositeError(code: errorCode,
                                  error: errorState.error)
    }
}

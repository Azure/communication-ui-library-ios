//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ErrorManagerProtocol {
}

class CompositeErrorManager: ErrorManagerProtocol {
    private let store: Store<AppState, Action>
    private let eventsHandler: CallComposite.Events
    private var previousError: CallCompositeInternalError?

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>,
         callCompositeEventsHandler: CallComposite.Events) {
        self.store = store
        self.eventsHandler = callCompositeEventsHandler
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
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
              let compositeError = getCallCompositeError(errorState: errorState) else {
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
        store.dispatch(action: .compositeExitAction)
    }

    private func getCallCompositeError(errorState: ErrorState) -> CallCompositeError? {
        guard let internalError = errorState.internalError,
              let errorCode = internalError.toCallCompositeErrorCode() else {
            return nil
        }

        return CallCompositeError(code: errorCode,
                                  error: errorState.error)
    }
}

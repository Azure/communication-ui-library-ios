//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ErrorManager {
}

class CompositeErrorManager: ErrorManager {
    private let store: Store<AppState>
    private weak var eventsHandler: CallCompositeEventsHandler?
    private var error: ErrorEvent?

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         callCompositeEventsHandler: CallCompositeEventsHandler?) {
        self.store = store
        self.eventsHandler = callCompositeEventsHandler
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        if let error = state.errorState.error {
            switch state.errorState.errorCategory {
            case .fatal:
                update(error: error)
                respondToFatalError(code: error.code)
                store.dispatch(action: CallingAction.CleanupCallStates())
            case .callState:
                update(error: error)
                store.dispatch(action: CallingAction.CleanupCallStates())
            case .none:
                break
            }
        }
    }

    private func update(error: ErrorEvent) {
        guard self.error != error else {
            return
        }

        self.error = error
        guard let eventsHandler = eventsHandler,
              let didFail = eventsHandler.didFail else {
            return
        }
        didFail(error)
    }

    private func respondToFatalError(code: String) {
        if code == CallCompositeErrorCode.tokenExpired ||
            code == CallCompositeErrorCode.callJoin ||
            code == CallCompositeErrorCode.callEnd {
            store.dispatch(action: CompositeExitAction())
        }
    }
}

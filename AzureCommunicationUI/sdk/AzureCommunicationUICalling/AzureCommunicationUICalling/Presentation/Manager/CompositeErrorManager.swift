//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ErrorManagerProtocol {
}

class CompositeErrorManager: ErrorManagerProtocol {
    private let store: Store<AppState>
    private let eventsHandler: CallComposite.Events
    private var error: CallCompositeErrorEvent?

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
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
        if let error = state.errorState.error {
            switch state.errorState.errorCategory {
            case .fatal:
                update(error: error)
                respondToFatalError(code: error.code)
            case .callState:
                update(error: error)
            case .none:
                break
            }
        }
    }

    private func update(error: CallCompositeErrorEvent) {
        guard self.error != error else {
            return
        }

        self.error = error
        guard error.code != CallCompositeErrorCode.callEvicted,
              error.code != CallCompositeErrorCode.callDenied,
              let didFail = eventsHandler.onError else {
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

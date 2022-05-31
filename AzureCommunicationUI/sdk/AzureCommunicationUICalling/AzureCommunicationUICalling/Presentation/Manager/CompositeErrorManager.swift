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
    private let eventsHandler: CallCompositeEventsHandling
    private var error: CallCompositeErrorEvent?

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         callCompositeEventsHandler: CallCompositeEventsHandling) {
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
        guard isPublicErrorCode(error.code),
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

    private func isPublicErrorCode(_ errorCode: String) -> Bool {
        guard errorCode != CallCompositeErrorCode.callEvicted,
              errorCode != CallCompositeErrorCode.callDenied,
              errorCode != CallCompositeErrorCode.callResume,
              errorCode != CallCompositeErrorCode.callHold else {
            return false
        }

        return true
    }
}

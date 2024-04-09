//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ExitManagerProtocol {
    func dismiss()
    func onDismissed()
}

class CompositeExitManager: ExitManagerProtocol {
    private let store: Store<AppState, Action>
    private let eventsHandler: CallComposite.Events
    private var previousError: CallCompositeInternalError?

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>,
         callCompositeEventsHandler: CallComposite.Events) {
        self.store = store
        self.eventsHandler = callCompositeEventsHandler
    }

    func dismiss() {
        if store.state.callingState.status == CallingStatus.none
            || store.state.callingState.status == CallingStatus.disconnected {
            store.dispatch(action: .compositeExitAction)
        } else {
            store.dispatch(action: .callingAction(.callEndRequested))
        }
    }

    func onDismissed() {
        updateEventHandler()
    }

    private func updateEventHandler() {
        guard let onDismissed = eventsHandler.onDismissed else {
            return
        }
        guard let compositeError = getCallCompositeError(errorState: store.state.errorState) else {
            onDismissed(CallCompositeDismissed(errorCode: nil, error: nil))
            return
        }
        onDismissed(CallCompositeDismissed(errorCode: compositeError.code, error: compositeError.error))
   }

    private func getCallCompositeError(errorState: ErrorState) -> CallCompositeError? {
        if store.state.errorState.errorCategory == ErrorCategory.fatal {
            guard let internalError = errorState.internalError,
                  let errorCode = internalError.toCallCompositeErrorCode() else {
                return nil
            }
            return CallCompositeError(code: errorCode,
                                      error: errorState.error)
        }
        return nil
    }
}

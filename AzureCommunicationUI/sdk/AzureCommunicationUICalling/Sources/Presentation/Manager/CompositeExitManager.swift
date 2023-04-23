//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ExitManagerProtocol {
    func exit()
    func onExited()
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

    func exit() {
        if store.state.callingState.status == CallingStatus.none
            || store.state.callingState.status == CallingStatus.disconnected {
            store.dispatch(action: .compositeExitAction)
        } else {
            store.dispatch(action: .callingAction(.callEndRequested))
        }
    }

    func onExited() {
        updateEventHandler()
    }

    private func updateEventHandler() {
        guard let onExit = eventsHandler.onExited else {
            return
        }
        onExit(CallCompositeExit(error: store.state.errorState.error))
    }
}

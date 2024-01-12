//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol CallStateManagerProtocol {
}

class CallStateManager: CallStateManagerProtocol {
    private let store: Store<AppState, Action>
    private let eventsHandler: CallComposite.Events
    private var previousCallingStatus: CallingStatus?

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
        let callingStatus = state.callingState.status
        guard previousCallingStatus != callingStatus else {
            return
        }
        previousCallingStatus = callingStatus
        updateEventHandler(state.callingState)
    }

    private func updateEventHandler(_ callingState: CallingState) {
        guard let onCallStateChanged = eventsHandler.onCallStateChanged else {
            return
        }
        onCallStateChanged(CallState(rawValue: callingState.status.toCallCompositeCallState().requestString,
                                     callEndReasonCode: callingState.callEndReasonCode,
                                     callEndReasonSubCode: callingState.callEndReasonSubCode))
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol EventManagerProtocol {}

class EventManager: EventManagerProtocol {
    private let store: Store<AppState>
    private let eventsHandler: ChatComposite.Events
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         chatCompositeEventsHandler: ChatComposite.Events) {
        self.store = store
        self.eventsHandler = chatCompositeEventsHandler
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        // MARK: Handle Local User Removal
        let participantState = state.participantsState
        if participantState.localParticipantStatus == .removed,
            let handler = eventsHandler.onLocalUserRemoved {
            handler()
        }
    }

}

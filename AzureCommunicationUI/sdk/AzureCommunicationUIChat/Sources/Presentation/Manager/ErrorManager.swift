//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol ErrorManagerProtocol {
}

class ErrorManager: ErrorManagerProtocol {
    private let store: Store<AppState>
    private let eventsHandler: ChatComposite.Events
    private var previousError: ChatCompositeInternalError?

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
        // stub not implemented
    }
}

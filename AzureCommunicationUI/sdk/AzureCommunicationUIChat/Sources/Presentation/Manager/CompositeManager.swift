//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CompositeManagerProtocol {
    func start()
}

class CompositeManager: CompositeManagerProtocol {
    private let logger: Logger
    private let store: Store<AppState>

    init(store: Store<AppState>,
         logger: Logger) {
        self.logger = logger
        self.store = store
    }

    func start() {
        store.dispatch(action: .chatAction(.initializeChat))
    }
}

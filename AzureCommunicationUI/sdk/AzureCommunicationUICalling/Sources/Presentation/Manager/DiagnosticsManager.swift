//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol DiagnosticsManagerProtocol {
    func getCallId() -> String
}

class DiagnosticsManager: DiagnosticsManagerProtocol {
    private let store: Store<AppState>

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>) {
        self.store = store
        self.store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        // Receive the callid from callstate
        // Assign CallId to local property
    }

    func getCallId() -> String {
        return ""
    }
}

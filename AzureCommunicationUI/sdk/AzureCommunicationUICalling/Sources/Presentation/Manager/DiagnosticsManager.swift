//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol DiagnosticsManagerProtocol {
    var callId: String? { get }
}

class DiagnosticsManager: DiagnosticsManagerProtocol {
    private let store: Store<AppState>
    private var cancellables = Set<AnyCancellable>()
    private(set) var callId: String?

    init(store: Store<AppState>) {
        self.store = store
        self.store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        // call id should be persisted after a call is finished
        guard let updatedCallId = state.callingState.callId,
              !updatedCallId.isEmpty else {
            return
        }

        callId = state.callingState.callId
    }
}

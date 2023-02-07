//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CallHistoryServiceProtocol {
}

class CallHistoryService: CallHistoryServiceProtocol {
    private let store: Store<AppState, Action>
    private var cancellables = Set<AnyCancellable>()
    private let callHistoryRepository: CallHistoryRepositoryProtocol
    private var updatedCallId: String?

    init(store: Store<AppState, Action>, callHistoryRepository: CallHistoryRepositoryProtocol) {
        self.callHistoryRepository = callHistoryRepository
        self.store = store

        self.store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }
            .store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        guard let updatedCallId = state.callingState.callId,
                !updatedCallId.isEmpty,
              let callStartDate = state.callingState.callStartDate,
              self.updatedCallId != updatedCallId else {
            return
        }
        self.updatedCallId = updatedCallId

        callHistoryRepository.insert(callStartedOn: callStartDate, callId: updatedCallId)
    }
}

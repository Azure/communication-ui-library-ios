//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class CallHistoryService {
    private let store: Store<AppState, Action>
    private var cancellables = Set<AnyCancellable>()
    private let callHistoryRepository: CallHistoryRepository
    private var updatedCallId: String?

    init(store: Store<AppState, Action>, callHistoryRepository: CallHistoryRepository) {
        self.callHistoryRepository = callHistoryRepository
        self.store = store

        self.store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }
            .store(in: &cancellables)
    }

    func receive(_ state: AppState) {
        guard let updatedCallId = state.callingState.callId,
                !updatedCallId.isEmpty,
              let callStartDate = state.callingState.callStartDate,
              self.updatedCallId != updatedCallId else {
            return
        }
        self.updatedCallId = updatedCallId
        recordCallHistory(callStartedOn: callStartDate, callId: updatedCallId)
    }

    func recordCallHistory(callStartedOn: Date, callId: String) {
        Task { @MainActor in
            let error = await self.callHistoryRepository.insert(callStartedOn: callStartedOn, callId: callId)
        }
    }
}

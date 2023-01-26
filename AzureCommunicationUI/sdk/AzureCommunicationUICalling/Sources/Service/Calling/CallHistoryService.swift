//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CallHistoryServiceProtocol {
}

class CallHistoryService: CallHistoryServiceProtocol {
    private let store: Store<AppState>
    private var cancellables = Set<AnyCancellable>()
    private let callHistoryRepository: CallHistoryRepositoryProtocol
    private var updatedCallId: String?

    init(store: Store<AppState>, callHistoryRepository: CallHistoryRepositoryProtocol) {
        self.callHistoryRepository = callHistoryRepository
        self.store = store

        cleanOldRecords()

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

        callHistoryRepository.insert(callDate: callStartDate, callId: updatedCallId)
    }

    private func cleanOldRecords() {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = -31
        if let thresholdDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) {
            let callRecords = callHistoryRepository.getAll()
            let callRecordIds = callRecords
                .filter { callHistoryRecord in
                    thresholdDate > callHistoryRecord.date
                }
                .map { callHistoryRecord in
                    callHistoryRecord.id
                }
            callHistoryRepository.remove(ids: callRecordIds)
        }
    }
}

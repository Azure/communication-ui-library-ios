//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol DebugInfoManagerProtocol {
    func getDebugInfo() -> DebugInfo
}

class DebugInfoManager: DebugInfoManagerProtocol {

    private let callHistoryRepository: CallHistoryRepositoryProtocol

    init(callHistoryRepository: CallHistoryRepositoryProtocol) {
        self.callHistoryRepository = callHistoryRepository
    }

    func getDebugInfo() -> DebugInfo {
        return DebugInfo(callHistoryRecordList: getCallHistory())
    }

    private func getCallHistory() -> [CallHistoryRecord] {

        let callHistoryRecords = callHistoryRepository.getAll()
        let grouped = Dictionary(grouping: callHistoryRecords, by: { $0.date })

        let mapped = grouped.map({ (callDate: Date, callRecord: [CallHistoryRecordData]) in
            return CallHistoryRecord(callStartedOn: callDate, callIds: callRecord.map { $0.callId })
        })

        let sorted = mapped.sorted(by: { a, b in
            return a.callStartedOn > b.callStartedOn
        })

        return sorted
    }
}

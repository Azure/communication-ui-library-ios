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
    private let callHistoryRepository: CallHistoryRepository

    init(callHistoryRepository: CallHistoryRepository) {
        self.callHistoryRepository = callHistoryRepository
    }

    /// The history of calls up to 30 days. Ordered ascending by call started date.
    func getDebugInfo() -> DebugInfo {
        return DebugInfo(callHistoryRecords: getCallHistory())
    }

    private func getCallHistory() -> [CallHistoryRecord] {
        return callHistoryRepository.getAll()
            .sorted(by: { a, b in
                return a.callStartedOn < b.callStartedOn
            })
    }
}

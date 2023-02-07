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
        return DebugInfo(callHistoryRecords: getCallHistory())
    }

    private func getCallHistory() -> [CallHistoryRecord] {
        return callHistoryRepository.getAll()
            .map({ (callStartedOn, callIds) in
                return CallHistoryRecord(callStartedOn: callStartedOn, callIds: callIds)
            })
            .sorted(by: { a, b in
                return a.callStartedOn < b.callStartedOn
            })
    }
}

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
    private let getLogFiles: () -> [URL]
    init(callHistoryRepository: CallHistoryRepository, getLogFiles: @escaping () -> [URL]) {
        self.callHistoryRepository = callHistoryRepository
        self.getLogFiles = getLogFiles
    }

    /// The history of calls up to 30 days. Ordered ascending by call started date.
    func getDebugInfo() -> DebugInfo {
        let version = Bundle(for: CallComposite.self).infoDictionary?["UILibrarySemVersion"]
        let versionStr = version as? String ?? "unknown"
        return DebugInfo(callHistoryRecords: getCallHistory(),
                         callingUIVersion: versionStr,
                         logFiles: self.getLogFiles())
    }

    private func getCallHistory() -> [CallHistoryRecord] {
        return callHistoryRepository.getAll()
            .sorted(by: { a, b in
                return a.callStartedOn < b.callStartedOn
            })
    }
}

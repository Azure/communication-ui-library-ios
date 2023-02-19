//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class CallHistoryRepository {
    private let callHistoryDispatchQueue = DispatchQueue(label: "CallHistoryDispatchQueue")
    private let storageKey: String = "com.azure.ios.communication.ui.calling.CallHistory"
    private let logger: Logger
    private let userDefaults: UserDefaults

    init(logger: Logger, userDefaults: UserDefaults) {
        self.logger = logger
        self.userDefaults = userDefaults
    }

    func insert(callStartedOn: Date, callId: String) {
        callHistoryDispatchQueue.async {
            var historyRecords = self.getAllAsDictionary()
            if let thresholdDate = Calendar.current.date(byAdding: DateComponents(day: -31), to: Date()) {
                historyRecords = historyRecords.filter { callHistoryRecord in
                    callHistoryRecord.key >= thresholdDate
                }
                if var existingCalls = historyRecords[callStartedOn] {
                    existingCalls.append(callId)
                    historyRecords[callStartedOn] = existingCalls
                } else {
                    historyRecords[callStartedOn] = [callId]
                }
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(historyRecords)
                    self.userDefaults.set(data, forKey: self.storageKey)
                } catch let error {
                    self.logger.error("Failed to save call history, reason: \(error.localizedDescription)")
                }
            }
        }
    }

    func getAll() -> [CallHistoryRecord] {
        return getAllAsDictionary()
            .map({ (callStartedOn, callIds) in
                return CallHistoryRecord(callStartedOn: callStartedOn, callIds: callIds)
            })
    }

    private func getAllAsDictionary() -> [Date: [String]] {
        if let data = userDefaults.data(forKey: storageKey) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode([Date: [String]].self, from: data)
            } catch {
                return [:]
            }
        }
        return [:]
    }
}

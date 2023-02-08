//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CallHistoryRepositoryProtocol {
    func insert(callStartedOn: Date, callId: String)
    func getAll() -> [Date: [String]]
}

class CallHistoryRepository: CallHistoryRepositoryProtocol {
    private let storageKey: String = "com.azure.ios.communication.ui.calling.CallHistory"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func insert(callStartedOn: Date, callId: String) {
        var historyRecords = getAll()

        if let thresholdDate = Calendar.current.date(byAdding: DateComponents(day: -31), to: Date()) {
            historyRecords = historyRecords.filter { callHistoryRecord in
                callHistoryRecord.key > thresholdDate
            }

            if var existingCall = historyRecords[callStartedOn] {
                existingCall.append(callId)
            } else {
                historyRecords[callStartedOn] = [callId]
            }
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(historyRecords)
                userDefaults.set(data, forKey: storageKey)
            } catch { }
        }
    }

    func getAll() -> [Date: [String]] {
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

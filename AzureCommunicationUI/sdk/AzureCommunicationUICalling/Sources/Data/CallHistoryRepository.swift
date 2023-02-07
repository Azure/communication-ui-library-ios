//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SQLite3

protocol CallHistoryRepositoryProtocol {
    func insert(callStartedOn: Date, callId: String)
    func getAll() -> [Date: [String]]
}

class CallHistoryRepository: CallHistoryRepositoryProtocol {
    private let storageKey: String = "com.azure.android.communication.ui.calling.CallHistory"

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
                UserDefaults.standard.set(data, forKey: storageKey)
            } catch { }
        }
    }

    func getAll() -> [Date: [String]] {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
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

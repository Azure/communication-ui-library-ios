//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CallHistoryRepositoryProtocol {
    func insert(callId: String, callDateTime: Date)
    func getAll() -> [CallHistoryRecordData]
    func remove(id: Int64)
}

class CallHistoryRepository: CallHistoryRepositoryProtocol {
    func insert(callId: String, callDateTime: Date) {
    }

    func getAll() -> [CallHistoryRecordData] {
        return []
    }

    func remove(id: Int64) {

    }
}

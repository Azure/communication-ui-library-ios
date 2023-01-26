//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SQLite3

protocol CallHistoryRepositoryProtocol {
    func insert(callDate: Date, callId: String)
    func getAll() -> [CallHistoryRecordData]
    func remove(id: Int64)
}

class CallHistoryRepository: CallHistoryRepositoryProtocol {

    private let dbHelper: DBHelper
    private let dateFormat: String = "yyyy-MM-dd'T'hh:mm:SS"

    init(dbHelper: DBHelper) {
        self.dbHelper = dbHelper
    }

    func insert(callDate: Date, callId: String) {
        if let db = dbHelper.openDatabase() {
            let fmtr = DateFormatter()
            fmtr.dateFormat = dateFormat

            let sql = "INSERT INTO CallHistory (Date,CallId) VALUES('"
            + fmtr.string(from: callDate) + "','" + callId + "')"

            var result = sqlite3_exec(db, sql, nil, nil, nil)

            self.dbHelper.dbClose(db: db)
        }
    }

    func getAll() -> [CallHistoryRecordData] {
        var callHistory: [CallHistoryRecordData] = []
        if let db = dbHelper.openDatabase() {
            let fmtr = DateFormatter()
            fmtr.dateFormat = dateFormat

            let sql = "SELECT Id, Date, CallId FROM CallHistory ORDER BY Date ASC"
            var stmt: OpaquePointer?
            var result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

            if SQLITE_OK == result {
                result = sqlite3_step(stmt)
                while SQLITE_ROW == result {
                    let id: Int64 = sqlite3_column_int64(stmt, 0)
                    let dateStr = String(cString: sqlite3_column_text(stmt, 1))
                    let callId = String(cString: sqlite3_column_text(stmt, 2))
                    let date = fmtr.date(from: dateStr)!

                    let callHistoryRecordData = CallHistoryRecordData(id: id, callId: callId, date: date)
                    callHistory.append(callHistoryRecordData)

                    result = sqlite3_step(stmt)
                }
                sqlite3_finalize(stmt)
            }

            self.dbHelper.dbClose(db: db)
        }
        return callHistory
    }

    func remove(id: Int64) {

    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SQLite3

protocol CallHistoryRepositoryProtocol {
    func insert(callDate: Date, callId: String)
    func getAll() -> [CallHistoryRecordData]
    func remove(ids: [Int64])
}

class CallHistoryRepository: CallHistoryRepositoryProtocol {

    private let dbHelper: DBHelper
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    init(dbHelper: DBHelper) {
        self.dbHelper = dbHelper
    }

    func insert(callDate: Date, callId: String) {
        if let db = dbHelper.openDatabase() {
            let sql = "INSERT INTO CallHistory (Date,CallId) VALUES('"
            + dateFormatter.string(from: callDate) + "','" + callId + "')"

            sqlite3_exec(db, sql, nil, nil, nil)

            self.dbHelper.dbClose(db: db)
        }
    }

    func getAll() -> [CallHistoryRecordData] {
        var callHistory: [CallHistoryRecordData] = []
        if let db = dbHelper.openDatabase() {

            let sql = "SELECT Id, Date, CallId FROM CallHistory ORDER BY Date ASC"
            var stmt: OpaquePointer?
            var result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

            if SQLITE_OK == result {
                result = sqlite3_step(stmt)
                while SQLITE_ROW == result {
                    let id: Int64 = sqlite3_column_int64(stmt, 0)
                    let dateStr = String(cString: sqlite3_column_text(stmt, 1))
                    let callId = String(cString: sqlite3_column_text(stmt, 2))
                    if let date = dateFormatter.date(from: dateStr) {
                        let callHistoryRecordData = CallHistoryRecordData(id: id, callId: callId, date: date)
                        callHistory.append(callHistoryRecordData)

                        result = sqlite3_step(stmt)
                    }
                }
                sqlite3_finalize(stmt)
            }

            self.dbHelper.dbClose(db: db)
        }
        return callHistory
    }

    func remove(ids: [Int64]) {
        guard !ids.isEmpty else {
            return
        }
        if let db = dbHelper.openDatabase() {
            let idVals = ids.map { id in
                "'" + String(id) + "'"
            }
                .joined(separator: ",")

            let sql = "DELETE FROM CallHistory WHERE Id in (\(idVals))"
            sqlite3_exec(db, sql, nil, nil, nil)
            self.dbHelper.dbClose(db: db)
        }
    }
}

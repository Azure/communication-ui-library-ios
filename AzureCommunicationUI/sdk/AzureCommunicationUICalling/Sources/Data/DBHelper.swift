//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SQLite3

class DBHelper {
    private var dbIsOpen: Bool = false
    private var dbPath: String = ""
    private var dbName: String = "AzureCommunicationUICalling.sqlite"
    private var createTableString: String = """
CREATE TABLE IF NOT EXISTS CallHistory (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Date VARCHAR(36) NOT NULL,
    CallId VARCHAR(36) NOT NULL
);
"""

    init() {
        let fileURL = try? FileManager.default.url(for: .cachesDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false)
            .appendingPathComponent(dbName)
        self.dbPath = fileURL?.path ?? ""
        let db = openDatabase()
        if db != nil {
            createTable(db: db!)
            dbClose(db: db!)
        }
    }

    func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        var result = sqlite3_open(self.dbPath as String, &db)
        if SQLITE_OK != result {
            print("There is error in creating DB " + dbName)
            return nil
        }
        return db
    }

    func createTable(db: OpaquePointer?) {
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("\nContact table created.")
            } else {
                print("\nContact table is not created.")
            }
        } else {
            print("\nCREATE TABLE statement is not prepared.")
        }

        sqlite3_finalize(createTableStatement)
    }

    func dbClose(db: OpaquePointer) {
        let result = sqlite3_close(db)
    }
}

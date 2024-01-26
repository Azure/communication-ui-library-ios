//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class DebugInfoTests: XCTestCase {
    func test_debugInfoWorks() {
        guard let testUrl = URL(string: "https://www.microsoft.com") else {
            return
        }
        let debugInfo = DebugInfo(callHistoryRecords: [], callingUIVersion: "TEST", logFiles: [testUrl])
        XCTAssertEqual(debugInfo.callingUIVersion, "TEST")
        XCTAssertEqual(debugInfo.logFiles[0], testUrl)
        XCTAssertEqual(debugInfo.callHistoryRecords.count, 0)
    }
}

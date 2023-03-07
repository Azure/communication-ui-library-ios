//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallHistoryRepositoryTests: XCTestCase {
    private var testUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        testUserDefaults = UserDefaults(suiteName: #file)
        testUserDefaults.removePersistentDomain(forName: #file)
    }

    func test_callingHistoryRepository_whenRecordsInserted_shouldInsertInDefaultStorage() async {
        let callId1 = "call id 1"
        let callStartDate1 = Date()

        let sut = makeSUT(testUserDefaults)
        let records = sut.getAll()
        XCTAssertEqual(records.count, 0)
        let result = await sut.insert(callStartedOn: callStartDate1, callId: callId1)
        XCTAssertNil(result)
        let updatedRecords = sut.getAll()
        XCTAssertEqual(updatedRecords.count, 1)
    }

    func test_callingHistoryRepository_whenRecordsInserted_shouldReturnRecords2() async {

        let callId1 = "call id 1"
        let callId2 = "call id 2"
        let callStartDate1 = Calendar.current.date(byAdding: DateComponents(minute: -1), to: Date())!
        let callStartDate2 = Date()
        let olderThen31DaysDate = Calendar.current.date(byAdding: DateComponents(day: -32), to: Date())!

        let sut = makeSUT(testUserDefaults)
        var result = await sut.insert(callStartedOn: callStartDate1, callId: callId1)
        XCTAssertNil(result)
        result = await sut.insert(callStartedOn: callStartDate1, callId: callId2)
        XCTAssertNil(result)
        result = await sut.insert(callStartedOn: callStartDate2, callId: callId1)
        XCTAssertNil(result)
        result = await sut.insert(callStartedOn: olderThen31DaysDate, callId: callId2)
        XCTAssertNil(result)

        // Verify values
        let records = sut.getAll()
        var firstCall = records.first(where: { $0.callStartedOn == callStartDate1 })
        XCTAssertEqual(records.count, 2)
        firstCall = records.first(where: { $0.callStartedOn == callStartDate1 })
        let secondCall = records.first(where: { $0.callStartedOn == callStartDate2 })

        XCTAssertEqual(firstCall?.callStartedOn, callStartDate1)
        XCTAssertEqual(firstCall?.callIds.count, 2)
        XCTAssertEqual(firstCall?.callIds, [callId1, callId2])

        XCTAssertEqual(secondCall?.callIds.count, 1)
        XCTAssertEqual(secondCall?.callIds, [callId1])
    }
}

extension CallHistoryRepositoryTests {
    func makeSUT(_ userDefaults: UserDefaults) -> CallHistoryRepository {
        return CallHistoryRepository(
            logger: LoggerMocking(),
            userDefaults: userDefaults
        )
    }
}

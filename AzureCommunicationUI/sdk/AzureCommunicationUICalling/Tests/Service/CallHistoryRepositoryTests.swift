//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallHistoryRepositoryTests: XCTestCase {
    private var userDefaultsStorate: UserDefaultsStorageProtocol!
    override func setUp() {
        super.setUp()
        userDefaultsStorate = UserDefaultsStorageMocking()
    }

    override func tearDown() {
        super.tearDown()
        userDefaultsStorate = nil
    }

    func test_callingHistoryRepository_whenRecordsInserted_shouldReturnRecords() {
        let sut = makeSUT()
        let callId1 = "call id 1"
        let callStartDate1 = Date()

        var records = sut.getAll()
        XCTAssertEqual(records.count, 0)

        sut.insert(callStartedOn: callStartDate1, callId: callId1)

        let callId2 = "call id 2"
        sut.insert(callStartedOn: callStartDate1, callId: callId2)

        records = sut.getAll()
        var firstCall = records.first(where: { $0.callStartedOn == callStartDate1 })!

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(firstCall.callStartedOn, callStartDate1)
        XCTAssertEqual(firstCall.callIds.count, 2)
        XCTAssertTrue(firstCall.callIds.contains(callId1))
        XCTAssertTrue(firstCall.callIds.contains(callId2))

        let callStartDate2 = Date()
        sut.insert(callStartedOn: callStartDate2, callId: callId1)

        records = sut.getAll()
        XCTAssertEqual(records.count, 2)
        firstCall = records.first(where: { $0.callStartedOn == callStartDate1 })!
        var secondCall = records.first(where: { $0.callStartedOn == callStartDate2 })!

        XCTAssertEqual(firstCall.callStartedOn, callStartDate1)
        XCTAssertEqual(firstCall.callIds.count, 2)
        XCTAssertTrue(firstCall.callIds.contains(callId1))
        XCTAssertTrue(firstCall.callIds.contains(callId2))

        XCTAssertEqual(secondCall.callIds.count, 1)
        XCTAssertTrue(secondCall.callIds.contains(callId1))
    }

    func test_callingHistoryRepository_whenOutdatedRecordsInserted_shouldNotReturnOutdatedRecords() {
        let sut = makeSUT()
        let callId1 = "call id 1"
        let callStartDate = Date()

        sut.insert(callStartedOn: callStartDate, callId: callId1)

        var records = sut.getAll()
        XCTAssertEqual(records.count, 1)

        let olderThen31DaysDate = Calendar.current.date(byAdding: DateComponents(day: -32), to: Date())!

        sut.insert(callStartedOn: olderThen31DaysDate, callId: callId1)

        records = sut.getAll()
        XCTAssertEqual(records.count, 1)
    }
}

extension CallHistoryRepositoryTests {
    func makeSUT() -> CallHistoryRepository {
        let logger = LoggerMocking()
        return CallHistoryRepository(logger: logger, userDefaults: userDefaultsStorate)
    }
}

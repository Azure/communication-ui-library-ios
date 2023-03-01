//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallHistoryRepositoryTests: XCTestCase {
    func test_callingHistoryRepository_whenRecordsInserted_shouldInsertInDefaultStorage() {

        let setExpectation = XCTestExpectation(description: "Defaul user storage set call is expected")

        let callId1 = "call id 1"
        let callStartDate1 = Date()

        let userDefaultsStorate: UserDefaultsStorageProtocol = UserDefaultsStorageMocking(data: { _ in
            return nil
        }, set: { (_, _) in
            setExpectation.fulfill()
        })

        let sut = makeSUT(userDefaultsStorate)

        var records = sut.getAll()
        XCTAssertEqual(records.count, 0)

        sut.insert(callStartedOn: callStartDate1, callId: callId1)
        // CallHistoryService is saving call history record async, so we need to allow time to call repository
        wait(for: [setExpectation], timeout: 1)
    }

    func test_callingHistoryRepository_whenRecordsInserted_shouldReturnRecords2() {
        let setExpectation = XCTestExpectation(description: "Defaul user storage set call is expected")
        setExpectation.expectedFulfillmentCount = 4
        var values: [String: Any] = [:]

        let userDefaultsStorate: UserDefaultsStorageProtocol = UserDefaultsStorageMocking(data: { (key) in
            return values[key] as? Data
        }, set: { (value, key) in
            values[key] = value
            setExpectation.fulfill()
        })

        let callId1 = "call id 1"
        let callId2 = "call id 2"
        let callStartDate1 = Calendar.current.date(byAdding: DateComponents(minute: -1), to: Date())!
        let callStartDate2 = Date()
        let olderThen31DaysDate = Calendar.current.date(byAdding: DateComponents(day: -32), to: Date())!

        let sut = makeSUT(userDefaultsStorate)
        sut.insert(callStartedOn: callStartDate1, callId: callId1)
        sut.insert(callStartedOn: callStartDate1, callId: callId2)
        sut.insert(callStartedOn: callStartDate2, callId: callId1)
        sut.insert(callStartedOn: olderThen31DaysDate, callId: callId2)
        wait(for: [setExpectation], timeout: 1)

        var records = sut.getAll()
        var firstCall = records.first(where: { $0.callStartedOn == callStartDate1 })!
        XCTAssertEqual(records.count, 2)
        firstCall = records.first(where: { $0.callStartedOn == callStartDate1 })!
        var secondCall = records.first(where: { $0.callStartedOn == callStartDate2 })!

        XCTAssertEqual(firstCall.callStartedOn, callStartDate1)
        XCTAssertEqual(firstCall.callIds.count, 2)
        XCTAssertEqual(firstCall.callIds, [callId1, callId2])

        XCTAssertEqual(secondCall.callIds.count, 1)
        XCTAssertEqual(secondCall.callIds, [callId1])
    }
}

extension CallHistoryRepositoryTests {
    func makeSUT(_ userDefaultsStorate: UserDefaultsStorageProtocol) -> CallHistoryRepository {
        let logger = LoggerMocking()
        return CallHistoryRepository(logger: logger, userDefaults: userDefaultsStorate)
    }
}

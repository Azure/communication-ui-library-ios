//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallHistoryServiceTests: XCTestCase {
    private var callHistoryRepository: CallHistoryRepositoryMocking!
    private var storeFactory: StoreFactoryMocking!
    override func setUp() {
        super.setUp()
        callHistoryRepository = CallHistoryRepositoryMocking()
        storeFactory = StoreFactoryMocking()
    }

    override func tearDown() {
        super.tearDown()
        callHistoryRepository = nil
    }

    func test_callingHistoryService_whenCallIDChanges_shouldCallinsertOnRepository() {
        let sut = makeSUT()
        let callId = "call id"
        let callStartDate = Date()
        XCTAssertFalse(callHistoryRepository.insertWasCalled())

        sut.receive(AppState(callingState: CallingState(callStartDate: callStartDate)))
        // CallHistoryService is saving call history record async, so we need to allow time to call repository
        Thread.sleep(forTimeInterval: 5)

        XCTAssertFalse(callHistoryRepository.insertWasCalled())
        sut.receive(AppState(callingState: CallingState(callId: callId)))
        Thread.sleep(forTimeInterval: 5)

        XCTAssertFalse(callHistoryRepository.insertWasCalled())

        sut.receive(AppState(callingState: CallingState(callId: callId, callStartDate: callStartDate)))
        Thread.sleep(forTimeInterval: 5)

        XCTAssertTrue(callHistoryRepository.insertWasCalled())
        let newCallId = "new call id"

        sut.receive(AppState(callingState: CallingState(callId: newCallId, callStartDate: callStartDate)))
        Thread.sleep(forTimeInterval: 5)

        XCTAssertTrue(callHistoryRepository.insertCallCount == 2)
    }
}

extension CallHistoryServiceTests {
    func makeSUT() -> CallHistoryService {
        return CallHistoryService(store: storeFactory.store, callHistoryRepository: callHistoryRepository)
    }
}

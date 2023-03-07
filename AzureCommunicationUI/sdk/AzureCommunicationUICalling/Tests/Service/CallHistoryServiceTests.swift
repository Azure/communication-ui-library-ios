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
    private var testUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testUserDefaults = UserDefaults(suiteName: #file)
        testUserDefaults.removePersistentDomain(forName: #file)
        callHistoryRepository = CallHistoryRepositoryMocking(userDefaults: testUserDefaults)
        storeFactory = StoreFactoryMocking()
    }

    override func tearDown() {
        super.tearDown()
        callHistoryRepository = nil
        storeFactory = nil
    }

    func test_callingHistoryService_whenCallIDChanges_shouldCallinsertOnRepository() {
        let sut = makeSUT()
        let callId = "call id"
        let callStartDate = Date()
        XCTAssertFalse(callHistoryRepository.insertWasCalled())

        sut.receive(AppState(callingState: CallingState(callStartDate: callStartDate)))

        XCTAssertFalse(sut.recordCallHistoryWasCalled())
        sut.receive(AppState(callingState: CallingState(callId: callId)))

        XCTAssertFalse(sut.recordCallHistoryWasCalled())

        sut.receive(AppState(callingState: CallingState(callId: callId, callStartDate: callStartDate)))

        XCTAssertTrue(sut.recordCallHistoryWasCalled())
        let newCallId = "new call id"

        sut.receive(AppState(callingState: CallingState(callId: newCallId, callStartDate: callStartDate)))

        XCTAssertTrue(sut.recordCallHistoryCallCount == 2)
    }
}

extension CallHistoryServiceTests {
    func makeSUT() -> CallHistoryServiceMocking {
        return CallHistoryServiceMocking(store: storeFactory.store, callHistoryRepository: callHistoryRepository)
    }
}

/* <TIMER_TITLE_FEATURE>
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

</TIMER_TITLE_FEATURE> */
import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallDurationManagerTests: XCTestCase {

    var callDurationManager: CallDurationManager!

    override func setUp() {
        super.setUp()
        callDurationManager = CallDurationManager()
    }

    override func tearDown() {
        callDurationManager = nil
        super.tearDown()
    }

    func testInitialValues() {
        XCTAssertEqual(callDurationManager.timeElapsed, 0)
        XCTAssertEqual(callDurationManager.timerTickStateFlow, "")
        XCTAssertFalse(callDurationManager.isStarted)
    }

    func testOnStart() {
        callDurationManager.onStart()
        XCTAssertTrue(callDurationManager.isStarted)
        XCTAssertNotNil(callDurationManager.timer)
    }

    func testOnStop() {
        callDurationManager.onStart()
        callDurationManager.onStop()
        XCTAssertFalse(callDurationManager.isStarted)
        XCTAssertNil(callDurationManager.timer)
        XCTAssertEqual(callDurationManager.timeElapsed, 0)
    }

    func testOnReset() {
        callDurationManager.onStart()
        callDurationManager.onReset()
        XCTAssertEqual(callDurationManager.timeElapsed, 0)
        XCTAssertEqual(callDurationManager.timerTickStateFlow, "00:00")
    }

    func testTimerTick() {
        callDurationManager.onStart()
        let expectation = self.expectation(description: "Timer tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.callDurationManager.timeElapsed, 2)
            XCTAssertEqual(self.callDurationManager.timerTickStateFlow, "00:02")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
}
/* </TIMER_TITLE_FEATURE> */

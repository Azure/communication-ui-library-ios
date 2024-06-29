//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling // Replace with your module name

class ThrottleMiddlewareTests: XCTestCase {
    enum TestAction {
        case action1
        case action2(Int)
        case action3
    }

    private func actionKeyGenerator(for action: TestAction) -> String? {
        switch action {
        case .action1:
            return "TestAction.action1"
        case .action2(let param):
            return "TestAction.action2.\(param)"
        case .action3:
            return nil // action3 should not be throttled
        }
    }

    func testThrottler_AllowsFirstAction() {
        let throttler = Throttler<TestAction>(timeoutS: 0.4, actionKeyGenerator: actionKeyGenerator)

        XCTAssertTrue(throttler.shouldProcess(action: .action1))
    }

    func testThrottler_ThrottlesSubsequentActionsWithinTimeout() {
        let throttler = Throttler<TestAction>(timeoutS: 0.5, actionKeyGenerator: actionKeyGenerator)

        XCTAssertTrue(throttler.shouldProcess(action: .action1))

        // Simulate subsequent action being dispatched quickly
        XCTAssertFalse(throttler.shouldProcess(action: .action1))
    }

    func testThrottler_AllowsActionsAfterTimeout() {
        let throttler = Throttler<TestAction>(timeoutS: 0.5, actionKeyGenerator: actionKeyGenerator)

        XCTAssertTrue(throttler.shouldProcess(action: .action1))

        // Simulate waiting for the timeout to pass
        let expectation = self.expectation(description: "Waiting for throttle timeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertTrue(throttler.shouldProcess(action: .action1))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testThrottler_DoesNotThrottleDifferentActions() {
        let throttler = Throttler<TestAction>(timeoutS: 0.5, actionKeyGenerator: actionKeyGenerator)

        XCTAssertTrue(throttler.shouldProcess(action: .action1))
        XCTAssertTrue(throttler.shouldProcess(action: .action2(5)))
    }

    func testThrottler_ThrottlesOnlySpecifiedActions() {
        let throttler = Throttler<TestAction>(timeoutS: 0.5, actionKeyGenerator: actionKeyGenerator)

        XCTAssertTrue(throttler.shouldProcess(action: .action1))

        // action2 should be throttled with parameters
        XCTAssertTrue(throttler.shouldProcess(action: .action2(5)))
        XCTAssertFalse(throttler.shouldProcess(action: .action2(5)))
    }

    func testThrottler_DoesNotThrottleUnfilteredAction() {
        let throttler = Throttler<TestAction>(timeoutS: 0.5, actionKeyGenerator: actionKeyGenerator)

        XCTAssertTrue(throttler.shouldProcess(action: .action3))
        XCTAssertTrue(throttler.shouldProcess(action: .action3))
    }
}

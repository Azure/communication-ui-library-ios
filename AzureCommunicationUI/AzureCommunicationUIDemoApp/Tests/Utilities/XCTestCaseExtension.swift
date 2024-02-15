//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

extension XCTestCase {
    /// Waits for an element to exist within a given timeout.
    func wait(for element: XCUIElement, timeout: TimeInterval = 20.0) {
        logElementState("Before waiting for existence", element: element)

        let predicate = NSPredicate(format: "exists == true")
        let expectation = self.expectation(for: predicate, evaluatedWith: element, handler: nil)

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        handleWaitResult(result, for: element, withCondition: "exists == true", timeout: timeout)
    }

    /// Waits for an element to become enabled within a given timeout.
    func waitEnabled(for element: XCUIElement, timeout: TimeInterval = 20.0) {
        logElementState("Before waiting for enabled", element: element)

        let predicate = NSPredicate(format: "enabled == true")
        let expectation = self.expectation(for: predicate, evaluatedWith: element, handler: nil)

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        handleWaitResult(result, for: element, withCondition: "enabled == true", timeout: timeout)
    }

    /// Logs the state of the given element.
    private func logElementState(_ message: String, element: XCUIElement) {
        print("\(message): Enabled=\(element.isEnabled), Exists=\(element.exists), Hittable=\(element.isHittable), Frame=\(element.frame)")
    }

    /// Handles the result of a wait operation, logging details and asserting on failure.
    private func handleWaitResult(_ result: XCTWaiter.Result, for element: XCUIElement, withCondition condition: String, timeout: TimeInterval) {
        switch result {
        case .completed:
            print("Successfully waited for condition '\(condition)' within \(timeout) seconds.")
        default:
            // Re-log the element state for detailed diagnostics upon failure.
            logElementState("After waiting failed", element: element)
            XCTFail("Failed to wait for condition '\(condition)' within \(timeout) seconds. Final state: Enabled=\(element.isEnabled), Exists=\(element.exists), Hittable=\(element.isHittable), Frame=\(element.frame)")
        }
    }
}

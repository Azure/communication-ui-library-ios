//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

extension XCTestCase {
    func wait(for element: XCUIElement, timeout: TimeInterval = 20.0) {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = expectation(for: predicate, evaluatedWith: element, handler: nil)
        wait(for: [expectation], timeout: timeout)
    }

    func waitEnabled(for element: XCUIElement, timeout: TimeInterval = 20.0) {
        if element.isEnabled {
            return
        }
        let predicate = NSPredicate(format: "enabled == true")
        let expectation = expectation(for: predicate, evaluatedWith: element, handler: nil)
        wait(for: [expectation], timeout: timeout)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

extension XCUIElement {
    func setText(text: String?, application: XCUIApplication) {
        tap()
        UIPasteboard.general.string = text
        guard UIPasteboard.general.hasStrings else {
            typeText(text ?? "")
            return
        }

        while application.menuItems.count == 0 {
            doubleTap()
        }
        application.menuItems["Paste"].tap()
    }

    func resetText(text: String?, application: XCUIApplication) {
        tap()
        UIPasteboard.general.string = text
        while application.menuItems.count == 0 {
            tap(withNumberOfTaps: 3, numberOfTouches: 1)
        }
        application.menuItems["Paste"].tap()
    }
}

extension XCTestCase {
  func wait(for element: XCUIElement, timeout: TimeInterval = 10) {
    let predicate = NSPredicate(format: "exists == true")
    let expectation = expectation(for: predicate, evaluatedWith: element, handler: nil)
    wait(for: [expectation], timeout: timeout)
  }

    func waitEnabled(for element: XCUIElement, timeout: TimeInterval = 10) {
      let predicate = NSPredicate(format: "enabled == true")
      let expectation = expectation(for: predicate, evaluatedWith: element, handler: nil)
      wait(for: [expectation], timeout: timeout)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
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

    var isOn: Bool? {
        return (self.value as? String).map { $0 == "1" }
    }
}

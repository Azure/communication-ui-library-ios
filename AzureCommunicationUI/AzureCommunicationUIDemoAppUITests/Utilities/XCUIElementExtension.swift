//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

extension XCUIElement {
    func setText(text: String?, application: XCUIApplication) {
        tap()
        UIPasteboard.general.string = text
        doubleTap()
        application.menuItems.element(boundBy: 0).tap()
    }
}

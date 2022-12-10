//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppTokenTests: XCUITestBase {
    func testCallCompositeWithExpiredToken() {
        tapInterfaceFor(.swiftUI)
        app.buttons[AccessibilityId.settingsButtonAccessibilityID.rawValue].tap()
//        app.tap()
        let expiredTokenToggle = app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue]
        wait(for: expiredTokenToggle)
        // first tap doesn't trigger switch to be toggled
//        app.staticTexts["UI Library - Settings"].tap()
        expiredTokenToggle.tap()
        XCTAssertTrue(expiredTokenToggle.value as? String == "1")
        app.buttons["Close"].tap()
        app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue].tap()
        app.buttons[AccessibilityIdentifier.joinCallAccessibilityID.rawValue].tap()
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }

    func testCallCompositeWithEmptyToken() {
        tapInterfaceFor(.swiftUI)
        app.buttons[AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue].tap()

        XCTAssertFalse(app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue].isEnabled)
    }

    func testCallCompositeWithInvalidToken() {
        tapInterfaceFor(.swiftUI)
        app.buttons[AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue].tap()

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: "invalidToken", application: app)

        app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue].tap()
        app.buttons["Dismiss"].tap()
    }
}

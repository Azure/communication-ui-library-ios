//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppTokenTests: XCUITestBase {
    func testCallCompositeWithExpiredToken() {
        tapInterfaceFor(.swiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
        wait(for: app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue])
        let expiredTokenToggle = app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue]
        app.tap()
        expiredTokenToggle.tap()
        XCTAssertTrue(expiredTokenToggle.value as? String == "1")
        tapButton(accessibilityIdentifier: "Close")
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue, shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue, shouldWait: true)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }

    func testCallCompositeWithEmptyToken() {
        tapInterfaceFor(.swiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue)

        XCTAssertFalse(app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue].isEnabled)
    }

    func testCallCompositeWithInvalidToken() {
        tapInterfaceFor(.swiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: "invalidToken", application: app)

        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: "Dismiss", shouldWait: true)
    }
}

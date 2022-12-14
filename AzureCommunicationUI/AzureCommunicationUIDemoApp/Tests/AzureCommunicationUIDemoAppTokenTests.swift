//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppTokenTests: XCUITestBase {
    func testCallCompositeWithExpiredToken() {
        tapInterfaceFor(.callSwiftUI)
        toggleMockSDKWrapperSwitch(enable: false)
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
        wait(for: app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue])
        let expiredTokenToggle = app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue]
        app.tap()
        expiredTokenToggle.tap()
        XCTAssertTrue(expiredTokenToggle.value as? String == "1")
        tapButton(accessibilityIdentifier: "Close")
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }

    func testCallCompositeWithEmptyToken() {
        tapInterfaceFor(.callSwiftUI)
        toggleMockSDKWrapperSwitch(enable: false)
        tapButton(accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue)

        XCTAssertFalse(app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue].isEnabled)
    }

    func testCallCompositeWithInvalidToken() {
        tapInterfaceFor(.callSwiftUI)
        toggleMockSDKWrapperSwitch(enable: false)
        tapButton(accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: "invalidToken", application: app)

        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
        tapButton(accessibilityIdentifier: "Dismiss", shouldWait: true)
    }
}

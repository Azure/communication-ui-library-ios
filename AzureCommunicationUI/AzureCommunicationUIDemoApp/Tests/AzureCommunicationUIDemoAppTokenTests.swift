//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppTokenTests: XCUITestBase {
    func testCallCompositeWithExpiredToken() {
        tapInterfaceFor(.callUIKit)

        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
        wait(for: app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue])
        if #unavailable(iOS 16) {
            // for <iOS 16, the table is shown
            app.tables.firstMatch.swipeUp()
        } else {
            // for iOS 16, the collection is shown
            app.collectionViews.firstMatch.swipeUp()
        }

        let toggle = app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue]
        app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue].tap()
        XCTAssertEqual(toggle.isOn, true)

        closeDemoAppSettingsPage()

        startExperience(useCallingSDKMock: false)
        joinCall()
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }

    func testCallCompositeWithEmptyToken() {
        tapInterfaceFor(.callSwiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue)

        XCTAssertFalse(app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue].isEnabled)
    }

    func testCallCompositeWithInvalidToken() {
        tapInterfaceFor(.callSwiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue)
        let acsTokenTextField = app.textFields["ACS Token"]

        acsTokenTextField.tap()
        acsTokenTextField.typeText("invalidToken")

        startExperience(useCallingSDKMock: false)
        tapButton(accessibilityIdentifier: "Dismiss", shouldWait: true)
    }
}

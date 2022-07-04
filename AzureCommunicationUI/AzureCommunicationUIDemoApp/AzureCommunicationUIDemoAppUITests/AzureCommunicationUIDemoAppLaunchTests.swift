//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppLaunchTests: XCUITestBase {

    func testCallCompositeLaunch() {
        tapInterfaceFor(.uiKit)
    }

    func testCallCompositeWithExpiredToken() {
        tapInterfaceFor(.swiftUI)
        tapButton(
            accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue,
            shouldWait: false)
        app.tap()
        let toggle = app.switches[AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue]
        if toggle.waitForExistence(timeout: 3) {
            toggle.tap()
        }
        app.swipeDown(velocity: .fast)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                    shouldWait: true)
        tapDismissButtonIfNeeded()
    }

    func testCallCompositeWithEmptyToken() {
        tapInterfaceFor(.swiftUI)
        tapButton(
            accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue,
            shouldWait: false)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: "", application: app)
        let startExperienceButton = app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue]
        if startExperienceButton.waitForExistence(timeout: 3) {
            XCTAssertFalse(startExperienceButton.isEnabled)
        } else {
            XCTFail("Failed to find the start experience button")
        }
    }

    func testCallCompositeWithInvalidToken() {
        tapInterfaceFor(.swiftUI)
        tapButton(
            accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue,
            shouldWait: false)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: "invalidToken", application: app)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapDismissButtonIfNeeded()
    }

    func testCallCompositeJoinCallGroupCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue, shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
    }
}

extension AzureCommunicationUIDemoAppLaunchTests {
    private func tapDismissButtonIfNeeded() {
        let dismissBtn = app.buttons["Dismiss"]
        if dismissBtn.waitForExistence(timeout: 3) {
            dismissBtn.tap()
        }
    }
}

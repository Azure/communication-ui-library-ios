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
        enterExpiredAcsToken()
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
        tapButton(
            accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue,
            shouldWait: false)
        enterNewAcsToken()
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue, shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: false)
    }

    func testCallCompositeJoinCallTeamsCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        enterNewAcsToken()
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: false)
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
        toggleLeaveCallDrawer(leaveCall: false)
    }

    func testCallCompositeJoinCallTeamsCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        app.buttons["Token URL"].tap()
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: false)
    }
}

extension AzureCommunicationUIDemoAppLaunchTests {
    private func tapDismissButtonIfNeeded() {
        let dismissBtn = app.buttons["Dismiss"]
        if dismissBtn.waitForExistence(timeout: 3) {
            dismissBtn.tap()
        }
    }

    private func enterNewAcsToken() {
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue,
                    shouldWait: false)
        tapButton(accessibilityIdentifier: AccessibilityId.getNewAcstokenButtonAccessibilityID.rawValue,
                    shouldWait: false)
        app.waitForExistence(timeout: 1)
        app.buttons["Close"].tap()
    }

    private func enterExpiredAcsToken() {
        tapButton(
            accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue,
            shouldWait: false)
        app.tap()
        let toggle = app.switches[AccessibilityId.expiredAcstokenToggleAccessibilityID.rawValue]
        if toggle.waitForExistence(timeout: 3) {
            toggle.tap()
        }
        app.buttons["Close"].tap()
    }

    /// Toggles the leave call overlay  in the calling screen
    private func toggleLeaveCallDrawer(leaveCall: Bool) {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue, shouldWait: true)

        if leaveCall {
            let cell = app.tables.cells[AccessibilityIdentifier.leaveCallAccessibilityID.rawValue]
            if cell.waitForExistence(timeout: 3) {
                cell.tap()
            }
        }
    }
}

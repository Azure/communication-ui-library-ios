//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUI

class AzureCommunicationUIDemoAppCallTests: XCUITestBase {

    // MARK: End call tests

    func testCallCompositeEndCallGroupCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityIdentifier.startExperienceAccessibilityLabel.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityLabel.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityIdentifier.startExperienceAccessibilityLabel.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityLabel.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    func testCallCompositeEndCallGroupCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityIdentifier.startExperienceAccessibilityLabel.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityLabel.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityIdentifier.startExperienceAccessibilityLabel.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityLabel.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    // MARK: Private / helper functions

    /// Toggles the leave call overlay  in the calling screen
    private func toggleLeaveCallDrawer(leaveCall: Bool) {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityLabel.rawValue, shouldWait: true)

        if leaveCall {
            let cell = app.tables.cells[LocalizationKey.leaveCall.rawValue]
            if cell.waitForExistence(timeout: 3) {
                cell.tap()
            }
            XCTAssertTrue(app.buttons[AccessibilityIdentifier.startExperienceAccessibilityLabel.rawValue]
                .waitForExistence(timeout: 3))
        }
    }
}

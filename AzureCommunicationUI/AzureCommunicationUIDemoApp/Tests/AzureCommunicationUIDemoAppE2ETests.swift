//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppE2ETests: XCUITestBase {
    func testCallCompositeE2ETokenURLGroupCall() {
        tapInterfaceFor(.callUIKit)
        tapConnectionTokenType(.acsTokenUrl)
        e2eTest()
    }

    func testCallCompositeE2ETokenURLTeamsCall() {
        tapInterfaceFor(.callSwiftUI)
        tapConnectionTokenType(.acsTokenUrl)
        tapMeetingType(.teamsCall)
        e2eTest()
    }

    func testCallCompositeE2ETokenValueGroupCall() {
        tapInterfaceFor(.callSwiftUI)
        e2eTest()
    }

    func testCallCompositeE2ETokenValueTeamsCall() {
        tapInterfaceFor(.callUIKit)
        tapMeetingType(.teamsCall)
        e2eTest()
    }
    func testWhenLeaveCallConfirmationDisabled() {
        tapInterfaceFor(.callUIKit)
        tapMeetingType(.teamsCall)
        disableLeaveCallConfirmationToggle()
        joinCall()
        leaveCallWithoutConfirmation()
    }

    // MARK: Private / helper functions

    /// Toggles the leave call overlay  in the calling screen and triggers call end
    private func leaveCall() {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
                  shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.leaveCallAccessibilityID.rawValue)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }
    private func leaveCallWithoutConfirmation() {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
                  shouldWait: true)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }

    private func e2eTest() {
        startExperience()
        joinCall()
        leaveCall()
    }
}

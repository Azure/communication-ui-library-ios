//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppCallTests: XCUITestBase {

    func testJoinCallEndCallWithMockCallCallingSDKWrapperHandler() {
        tapInterfaceFor(.callUIKit)

        // turn on calling sdk mock in settings modal
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
        wait(for: app.switches[AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue])
        app.tap()
        let toggle = app.switches[AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue]
        toggle.tap()
        XCTAssertTrue(toggle.value as? String == "1")
        app.buttons["Close"].tap()

        // go to setup screen
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)

        // join call
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue, shouldWait: true)

        // mute / unmute local mic
        let micButton = app.buttons[AccessibilityIdentifier.micAccessibilityID.rawValue]
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue, shouldWait: true)
        XCTAssertEqual(micButton.label, "Mute")
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue)
        XCTAssertEqual(micButton.label, "Unmute")
        leaveCall()
    }

    // MARK: End call tests

    func testCallCompositeE2ETokenURLGroupCall() {
        tapInterfaceFor(.callUIKit)
        tapConnectionTokenType(.acsTokenUrl)
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue, shouldWait: true)
        leaveCall()
    }

    func testCallCompositeE2ETokenURLTeamsCall() {
        tapInterfaceFor(.callSwiftUI)
        tapConnectionTokenType(.acsTokenUrl)
        tapMeetingType(.teamsCall)
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue, shouldWait: true)
        leaveCall()
    }

    func testCallCompositeE2ETokenValueGroupCall() {
        tapInterfaceFor(.callSwiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue, shouldWait: true)
        leaveCall()
    }

    func testCallCompositeE2ETokenValueTeamsCall() {
        tapInterfaceFor(.callUIKit)
        tapMeetingType(.teamsCall)
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue, shouldWait: true)
        leaveCall()
    }

    // MARK: Private / helper functions

    /// Toggles the leave call overlay  in the calling screen and triggers call end
    private func leaveCall() {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue, shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.leaveCallAccessibilityID.rawValue, shouldWait: true)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppCallTests: XCUITestBase {

    func testJoinCallEndCallWithMockCallCallingSDKWrapperHandler() {
        tapInterfaceFor(.callUIKit)

        toggleMockSDKWrapperSwitch(enable: true)

        // go to setup screen
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)

        // join call
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        app.windows["debugger_Window"].buttons["Hold"].tap()
        let onHoldText = app.staticTexts["You're on hold"]
        XCTAssertTrue(onHoldText.exists)
        app.buttons[AccessibilityIdentifier.callResumeAccessibilityID.rawValue].tap()
        XCTAssertFalse(onHoldText.exists)

//        app.windows["debugger_Window"].buttons["Transcription on"].tap()
//        app.windows["debugger_Window"].buttons["Transcription off"].tap()
//        app.windows["debugger_Window"].buttons["Recording on"].tap()
//        app.windows["debugger_Window"].buttons["Recording off"].tap()

        let micButton = app.buttons[AccessibilityIdentifier.micAccessibilityID.rawValue]
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue, shouldWait: true)
        XCTAssertEqual(micButton.label, "Mute")
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue)
        XCTAssertEqual(micButton.label, "Unmute")

        // KG
        // toggleLeaveCallDrawer(leaveCall: true)
        // let draggablePipViewRetest = app.otherElements[AccessibilityIdentifier.draggablePipViewAccessibilityID.rawValue]
        // XCTAssertFalse(draggablePipViewRetest.exists)

        leaveCall()
    }

    // MARK: End call tests
    func testCallCompositeE2ETokenURLGroupCall() {
        tapInterfaceFor(.callUIKit)
        toggleMockSDKWrapperSwitch(enable: true)
        tapConnectionTokenType(.acsTokenUrl)
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)
        leaveCall()
    }

    func testCallCompositeE2ETokenURLTeamsCall() {
        tapInterfaceFor(.callSwiftUI)
        toggleMockSDKWrapperSwitch(enable: true)
        tapConnectionTokenType(.acsTokenUrl)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)
        leaveCall()
    }

    func testCallCompositeE2ETokenValueGroupCall() {
        tapInterfaceFor(.callSwiftUI)
        toggleMockSDKWrapperSwitch(enable: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)
        leaveCall()
    }

    func testCallCompositeE2ETokenValueTeamsCall() {
        tapInterfaceFor(.callUIKit)
        tapMeetingType(.teamsCall)
        toggleMockSDKWrapperSwitch(enable: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)
        leaveCall()
    }

    // MARK: Private / helper functions

    /// Toggles the leave call overlay  in the calling screen and triggers call end
    private func leaveCall() {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue, shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.leaveCallAccessibilityID.rawValue)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }
}

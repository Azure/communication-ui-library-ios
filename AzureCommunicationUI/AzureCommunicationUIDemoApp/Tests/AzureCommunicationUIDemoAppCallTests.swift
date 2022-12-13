//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppCallTests: XCUITestBase {

    func testJoinCallEndCallWithMockCallCallingSDKWrapperHandler() {
        tapInterfaceFor(.uiKit)

        toggleMockSDKWrapperSwitch(enable: true)

        // go to setup screen
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        let buttonExist = app.buttons[AccessibilityIdentifier.joinCallAccessibilityID.rawValue].waitForExistence(timeout: 10)
        XCTAssertTrue(buttonExist)

        // join call
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)

        // mute / unmute local mic
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue,
                  shouldWait: true)

        app.windows["debugger_Window"].buttons["Hold"].forceTapElement()
        app.windows["debugger_Window"].buttons["Resume"].tap()
        app.windows["debugger_Window"].buttons["Transcription on"].tap()
        app.windows["debugger_Window"].buttons["Transcription off"].tap()
        app.windows["debugger_Window"].buttons["Recording on"].tap()
        app.windows["debugger_Window"].buttons["Recording off"].tap()

        let micButton = app.buttons[AccessibilityIdentifier.micAccessibilityID.rawValue]
        XCTAssertNotNil(micButton)
        XCTAssertTrue(micButton.isEnabled)
        XCTAssertEqual(micButton.label, "Mute")
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue,
                  shouldWait: true)
        XCTAssertEqual(micButton.label, "Unmute")

        toggleLeaveCallDrawer(leaveCall: true)
        let draggablePipViewRetest = app.otherElements[AccessibilityIdentifier.draggablePipViewAccessibilityID.rawValue]
        XCTAssertFalse(draggablePipViewRetest.exists)
    }

    // MARK: End call tests

    func testCallCompositeEndCallGroupCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        toggleMockSDKWrapperSwitch(enable: false)
        tapConnectionTokenType(.acsTokenUrl)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        toggleMockSDKWrapperSwitch(enable: false)
        tapConnectionTokenType(.acsTokenUrl)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    func testCallCompositeEndCallGroupCallUIKit() {
        tapInterfaceFor(.uiKit)
        toggleMockSDKWrapperSwitch(enable: false)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallUIKit() {
        tapInterfaceFor(.uiKit)
        toggleMockSDKWrapperSwitch(enable: false)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        toggleLeaveCallDrawer(leaveCall: true)
    }

    // MARK: Share call info
    func testCallCompositeShareDiagnosticInfo() {
        tapInterfaceFor(.uiKit)
        toggleMockSDKWrapperSwitch(enable: false)
        tapMeetingType(.groupCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.moreAccessibilityID.rawValue,
            shouldWait: true)
        tapCell(
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            shouldWait: true)
        wait(for: app.otherElements["ActivityListView"])
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.otherElements["PopoverDismissRegion"].tap()
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            tapButton(
                accessibilityIdentifier: AccessibilityIdentifier.activityViewControllerCloseButtonAccessibilityID.rawValue,
                shouldWait: true)
        }
        XCTAssertFalse(app.otherElements["ActivityListView"].exists)
    }

    func testCallCompositeCopyDiagnosticInfo() {
        tapInterfaceFor(.uiKit)
        toggleMockSDKWrapperSwitch(enable: false)
        tapMeetingType(.groupCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.moreAccessibilityID.rawValue,
            shouldWait: true)
        tapCell(
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            shouldWait: true)
        wait(for: app.otherElements[AccessibilityIdentifier.activityViewControllerAccessibilityID.rawValue])
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.activityViewControllerCopyButtonAccessibilityID.rawValue,
            shouldWait: true)
        XCTAssertFalse(app.otherElements[AccessibilityIdentifier.activityViewControllerAccessibilityID.rawValue].exists)
    }

    // MARK: Private / helper functions

    /// Toggles the leave call overlay  in the calling screen
    private func toggleLeaveCallDrawer(leaveCall: Bool) {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue, shouldWait: true)

        if leaveCall {
            let cell = app.tables.cells[AccessibilityIdentifier.leaveCallAccessibilityID.rawValue]
            if cell.waitForExistence(timeout: 3) {
                cell.tap()
            }
            XCTAssertTrue(app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue]
                .waitForExistence(timeout: 3))
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppCallTests: XCUITestBase {
    func testCallCompositeOnHoldHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        app.windows["debugger_Window"].buttons["Hold"].tap()
        let onHoldText = app.staticTexts["You're on hold"]
        XCTAssertTrue(onHoldText.exists)
        app.buttons[AccessibilityIdentifier.callResumeAccessibilityID.rawValue].tap()
        XCTAssertFalse(onHoldText.exists)
    }

    func testCallCompositeTranscriptionHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        app.windows["debugger_Window"].buttons["Transcription on"].tap()
        XCTAssertTrue(app.staticTexts["Transcription has started. By joining, you are giving consent for this meeting to be transcribed. Privacy policy"].exists)

        app.windows["debugger_Window"].buttons["Transcription off"].tap()
        XCTAssertTrue(app.staticTexts["Transcription is being saved. Transcription has stopped. Learn more"].exists)
    }

    func testCallCompositeRecordingHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        app.windows["debugger_Window"].buttons["Recording on"].tap()
        XCTAssertTrue(app.staticTexts["Recording has started. By joining, you are giving consent for this meeting to be transcribed. Privacy policy"].exists)
        app.windows["debugger_Window"].buttons["Recording off"].tap()
        XCTAssertTrue(app.staticTexts["Recording is being saved. Recording has stopped. Learn more"].exists)
    }

    func testCallCompositeCallMicrophoneHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        let micButton = app.buttons[AccessibilityIdentifier.micAccessibilityID.rawValue]
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue, shouldWait: true)
        XCTAssertEqual(micButton.label, "Mute")
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue)
        XCTAssertEqual(micButton.label, "Unmute")
    }

    func testCallCompositeCurrentParticipantOnlyCallNoPIP() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

         let draggablePipViewRetest = app.otherElements[AccessibilityIdentifier.draggablePipViewAccessibilityID.rawValue]
         XCTAssertFalse(draggablePipViewRetest.exists)
    }

    // MARK: Private / helper functions
    /// Toggles the leave call overlay  in the calling screen and triggers call end
    private func leaveCall() {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
                  shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.leaveCallAccessibilityID.rawValue)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }

    private func e2eTest() {
        startExperience()
        joinCall()
        leaveCall()
    }
}

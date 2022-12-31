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

        tapButton(accessibilityIdentifier: "Hold")
        let onHoldText = app.staticTexts["You're on hold"]
        XCTAssertTrue(onHoldText.exists)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.callResumeAccessibilityID.rawValue)
        XCTAssertFalse(onHoldText.exists)
    }

    func testCallCompositeTranscriptionHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Transcription on")
        // the text has trait link, so links should be  used instead of staticTexts
        XCTAssertTrue(app.links["Transcription has started. By joining, you are giving consent for this meeting to be transcribed. Privacy policy"].exists)

        tapButton(accessibilityIdentifier: "Transcription off")
        XCTAssertTrue(app.links["Transcription is being saved. Transcription has stopped. Learn more"].exists)
    }

    func testCallCompositeRecordingHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Recording on")
        // the text has trait link, so links should be  used instead of staticTexts
        XCTAssertTrue(app.links["Recording has started. By joining, you are giving consent for this meeting to be transcribed. Privacy policy"].exists)

        tapButton(accessibilityIdentifier: "Recording off")
        XCTAssertTrue(app.links["Recording is being saved. Recording has stopped. Learn more"].exists)
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

    func testCallCompositeCallAddRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add Participant")
        XCTAssertTrue(app.staticTexts["RM-1"].exists)

        tapButton(accessibilityIdentifier: "Unmute Participant")
        tapButton(accessibilityIdentifier: "Hold Participant")
    }

    func testCallCompositeCallHoldRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add Participant")
        XCTAssertTrue(app.staticTexts["RM-1"].exists)

        tapButton(accessibilityIdentifier: "Hold Participant")
        XCTAssertTrue(app.staticTexts["On hold"].exists)
    }
}

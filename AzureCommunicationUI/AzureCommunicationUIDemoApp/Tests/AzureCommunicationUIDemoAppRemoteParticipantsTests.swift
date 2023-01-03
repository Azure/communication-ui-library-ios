//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppRemoteParticipantsTests: XCUITestBase {
    func testCallCompositeAddRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add Participant")
        XCTAssertTrue(app.staticTexts["RM-1"].exists)
    }

    func testCallCompositeUnmuteRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add Participant")

        wait(for: app.staticTexts["RM-1 Muted"])
        tapButton(accessibilityIdentifier: "Unmute Participant")
        XCTAssertFalse(app.staticTexts["RM-1 Muted"].exists)
    }

    func testCallCompositeHoldRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add Participant")
        tapButton(accessibilityIdentifier: "Hold Participant")
        XCTAssertTrue(app.staticTexts["On hold"].exists)
    }
}

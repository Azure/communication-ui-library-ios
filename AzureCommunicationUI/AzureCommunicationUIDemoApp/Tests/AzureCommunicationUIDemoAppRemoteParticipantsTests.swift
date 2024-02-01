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

        let predicate = NSPredicate(format: "label CONTAINS %@", "RM-1")
        wait(for: app.staticTexts.element(matching: predicate))
    }

    func testCallCompositeAddInLobbyRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add InLobby Participant")

        wait(for: app.staticTexts["Waiting for others to join"])

        tapButton(accessibilityIdentifier: "Remove Participant")

        tapButton(accessibilityIdentifier: "Change role to Presenter")

        tapButton(accessibilityIdentifier: "Add InLobby Participant")

        wait(for: app.staticTexts["People are waiting to join."])
    }

    func testCallCompositeUnmuteRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add Participant")

        wait(for: app.staticTexts["RM-1 Muted"])
        tapButton(accessibilityIdentifier: "Unmute Participant")

        let mutedText = app.staticTexts["RM-1 Muted"]
        let predicate = NSPredicate(format: "exists == false")
        let expectation = expectation(for: predicate,
                                      evaluatedWith: mutedText) {
            return true
        }
        wait(for: [expectation], timeout: 20.0)
    }

    func testCallCompositeHoldRemoteParticipantHandler() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "Add Participant")
        tapButton(accessibilityIdentifier: "Hold Participant")
        wait(for: app.staticTexts["RM-1 On hold"])
    }
}

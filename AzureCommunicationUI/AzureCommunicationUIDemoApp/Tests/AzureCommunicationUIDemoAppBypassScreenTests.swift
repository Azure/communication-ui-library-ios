//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppBypassScreenTests: XCUITestBase {
    func testCallCompositeWithBypassEnabledJoinCall() {
        tapInterfaceFor(.callUIKit)
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)

        wait(for: app.switches[AccessibilityId.skipSetupScreenToggleAccessibilityID.rawValue])
        if #unavailable(iOS 16) {
            // for <iOS 16, the table is shown
            app.tables.firstMatch.swipeUp()
        } else {
            // for iOS 16, the collection is shown
            app.collectionViews.firstMatch.swipeUp()
        }
        let toggle = app.switches[AccessibilityId.skipSetupScreenToggleAccessibilityID.rawValue]
        app.switches[AccessibilityId.skipSetupScreenToggleAccessibilityID.rawValue].tap()
        XCTAssertEqual(toggle.isOn, true)

        closeDemoAppSettingsPage()

        startExperience(useCallingSDKMock: false)
        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])
    }

    func testCallCompositeBypassEnabledCallMicrophoneHandler() {
        tapInterfaceFor(.callSwiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)

        wait(for: app.switches[AccessibilityId.skipSetupScreenToggleAccessibilityID.rawValue])
        if #unavailable(iOS 16) {
            // for <iOS 16, the table is shown
            app.tables.firstMatch.swipeUp()
        } else {
            // for iOS 16, the collection is shown
            app.collectionViews.firstMatch.swipeUp()
        }
        let toggle = app.switches[AccessibilityId.skipSetupScreenToggleAccessibilityID.rawValue]
        app.switches[AccessibilityId.skipSetupScreenToggleAccessibilityID.rawValue].tap()
        XCTAssertEqual(toggle.isOn, true)

        closeDemoAppSettingsPage()
        startExperience(useCallingSDKMock: false)
        

        let micButton = app.buttons[AccessibilityIdentifier.micAccessibilityID.rawValue]
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue, shouldWait: true)
        XCTAssertEqual(micButton.label, "Mute")
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.micAccessibilityID.rawValue)
        XCTAssertEqual(micButton.label, "Unmute")
        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])
    }
}

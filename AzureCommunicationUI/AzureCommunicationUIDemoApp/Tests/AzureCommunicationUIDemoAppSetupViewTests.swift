//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppSetupViewTests: XCUITestBase {

    // MARK: Setup view tests
    func testCallCompositeSetupCallGroupCallSwiftUI() {
        tapInterfaceFor(.callSwiftUI)
        if #unavailable(iOS 14.2) {
            // there is an AppCenter issue for devices with iOS < 14.2 when useCallingSDKMock = false
            // that cause testCallCompositeSetupCallGroupCallSwiftUI to fail
            // however, the test can be run locally without any issues for all supported iOS versions (including iOS < 14.2)
            startExperience()
        } else {
            startExperience(useCallingSDKMock: false)
        }

        wait(for: app.buttons[AccessibilityIdentifier.joinCallAccessibilityID.rawValue])

        let audioButtonLabel = app.buttons[AccessibilityIdentifier.toggleMicAccessibilityID.rawValue].label
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleMicAccessibilityID.rawValue, shouldWait: true)
        check(predicate: NSPredicate(format: "label != %@", audioButtonLabel),
              for: app.buttons[AccessibilityIdentifier.toggleMicAccessibilityID.rawValue])

        let videoButtonLabel = app.buttons[AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue].label
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue)

        let audioDeviceButtonValue = app.buttons[AccessibilityIdentifier.toggleAudioDeviceAccessibilityID.rawValue].value as? String
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleAudioDeviceAccessibilityID.rawValue,
                  shouldWait: true)

        let cell = app.tables.cells.firstMatch
        wait(for: cell)
        cell.tap()
        if #unavailable(iOS 16) {
            sleep(1)
        }
        check(predicate: NSPredicate(format: "value != %@", audioDeviceButtonValue ?? ""),
              for: app.buttons[AccessibilityIdentifier.toggleAudioDeviceAccessibilityID.rawValue])

        // check for camera button is moved to the end as
        // video button invoke camera access alert on the first run and
        // this alert isn't considered an interruption
        // see Apple documentation for "Handling UI Interruptions" for more details
        check(predicate: NSPredicate(format: "label != %@", videoButtonLabel),
              for: app.buttons[AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: AccessibilityIdentifier.dismissButtonAccessibilityID.rawValue,
                  shouldWait: true)
        wait(for: app.buttons[AccessibilityId.startExperienceAccessibilityID.rawValue])
    }

    func check(predicate: NSPredicate, for element: XCUIElement) {
        let expectation = expectation(for: predicate,
                                      evaluatedWith: element) {
            return true
        }
        wait(for: [expectation], timeout: 20.0)
    }
}

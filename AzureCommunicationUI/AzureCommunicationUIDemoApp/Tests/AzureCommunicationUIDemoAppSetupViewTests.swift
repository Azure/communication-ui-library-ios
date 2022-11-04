//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppSetupViewTests: XCUITestBase {

    // MARK: Setup view tests

    func testCallCompositeSetupCallGroupCallSwiftUI() throws {
        guard !isUsingMockedCallingSDKWrapper() else {
            throw XCTSkip("CallingSDKWrapper mock test is in progress, non-mock test is skipped.")
        }
        tapInterfaceFor(.swiftUI)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue, shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.togglMicAccessibilityID.rawValue, shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.toggleAudioDeviceAccesibiiltyID.rawValue, shouldWait: true)
        let cell = app.tables.cells.firstMatch
        if cell.waitForExistence(timeout: 3) {
            cell.tap()
        }
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.togglMicAccessibilityID.rawValue, shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue, shouldWait: true)
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.dismisButtonAccessibilityID.rawValue, shouldWait: true)
    }
}

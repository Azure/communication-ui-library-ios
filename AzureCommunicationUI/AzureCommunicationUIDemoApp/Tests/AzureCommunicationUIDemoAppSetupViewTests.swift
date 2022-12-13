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
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)

        // shouldWait is set to true to finalize animations
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue, shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleMicAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleAudioDeviceAccessibilityID.rawValue)

        let cell = app.tables.cells.firstMatch
        wait(for: cell)
        cell.tap()

        // shouldWait is set to true to finalize animations
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue, shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleMicAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.dismissButtonAccessibilityID.rawValue, shouldWait: true)
    }
 }

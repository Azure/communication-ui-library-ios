//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

 class AzureCommunicationUIDemoAppSetupViewTests: XCUITestBase {

    // MARK: Setup view tests
    func testCallCompositeSetupCallGroupCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)

        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleMicAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleAudioDeviceAccessibilityID.rawValue)

        let cell = app.tables.cells.firstMatch
        wait(for: cell)
        cell.tap()

        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.toggleMicAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.dismissButtonAccessibilityID.rawValue)
    }
 }

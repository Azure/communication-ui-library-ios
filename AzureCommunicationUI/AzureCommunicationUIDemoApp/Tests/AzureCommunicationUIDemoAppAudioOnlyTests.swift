//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppAudioOnlyTests: XCUITestBase {
    func testCallCompositeAudioOnlyEnabled() {
        enterMenu()
        tapButton(accessibilityIdentifier: AccessibilityId.toggleAudioOnlyModeAccessibilityID.rawValue)
        startExperience()
        verifyButtonDoesNotExist(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue)
        joinCall()
        verifyButtonDoesNotExist(accessibilityIdentifier: AccessibilityIdentifier.videoAccessibilityID.rawValue)
    }

    func testCallCompositeNormalAvMode() {
        enterMenu()
        startExperience()
        verifyButtonExistsAndEnabled(accessibilityIdentifier: AccessibilityIdentifier.toggleVideoAccessibilityID.rawValue)
        joinCall()
        verifyButtonExistsAndEnabled(accessibilityIdentifier: AccessibilityIdentifier.videoAccessibilityID.rawValue)
    }
}

extension AzureCommunicationUIDemoAppAudioOnlyTests {
    func enterMenu() {
        tapInterfaceFor(.callSwiftUI)
        tapMeetingType(.groupCall)
    }
}

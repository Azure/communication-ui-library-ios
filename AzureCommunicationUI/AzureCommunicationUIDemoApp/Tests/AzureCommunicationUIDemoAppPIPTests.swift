//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppPIPTests: XCUITestBase {
    func testCallCompositeCurrentParticipantOnlyCallNoPIP() throws {
        try skipTestIfNeeded()
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        let draggablePipViewRetest = app.otherElements[AccessibilityIdentifier.draggablePipViewAccessibilityID.rawValue]
        XCTAssertFalse(draggablePipViewRetest.exists)
    }
}

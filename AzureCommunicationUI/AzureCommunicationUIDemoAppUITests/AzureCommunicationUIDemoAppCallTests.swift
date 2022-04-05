//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUI

class AzureCommunicationUIDemoAppCallTests: XCUITestBase {

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app?.launch()
    }

    // MARK: End call tests

    func testCallCompositeEndCallGroupCallSwiftUI() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallSwiftUI() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    func testCallCompositeEndCallGroupCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    // MARK: Private / helper functions

    /// Toggles the leave call overlay  in the calling screen
    private func toggleLeaveCallOverlay(leaveCall: Bool) {
        guard let app = app else {
            XCTFail("No App launch")
            return
        }

        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .cancelAccssibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)

        if leaveCall {
            tapButton(accessibilityIdentifier: .leaveCallAccssibilityLabel, shouldWait: true)
            XCTAssertTrue(app.buttons[LocalizationKey.startExperienceAccessibilityLabel.rawValue]
                            .waitForExistence(timeout: 3))
        }
    }
}

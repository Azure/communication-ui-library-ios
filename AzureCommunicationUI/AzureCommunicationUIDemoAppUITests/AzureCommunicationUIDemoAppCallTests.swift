//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

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
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        tapButton(buttonName: "Join call", shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallSwiftUI() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        tapButton(buttonName: "Join call", shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    func testCallCompositeEndCallGroupCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        tapButton(buttonName: "Join call", shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    func testCallCompositeEndCallTeamsCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        tapButton(buttonName: "Join call", shouldWait: true)
        toggleLeaveCallOverlay(leaveCall: true)
    }

    // MARK: Private / helper functions

    /// Toggles the leave call overlay  in the calling screen
    private func toggleLeaveCallOverlay(leaveCall: Bool) {
        guard let app = app else {
            XCTFail("No App launch")
            return
        }
        tapButton(buttonName: "AzureCommunicationUI.CallingView.ControlButton.HangUp", shouldWait: true)
        tapButton(buttonName: "Cancel", shouldWait: true)
        tapButton(buttonName: "AzureCommunicationUI.CallingView.ControlButton.HangUp", shouldWait: true)

        if leaveCall {
            tapButton(buttonName: "Leave call", shouldWait: true)
            XCTAssertTrue(app.buttons["Start Experience"].waitForExistence(timeout: 3))
        }
    }
}

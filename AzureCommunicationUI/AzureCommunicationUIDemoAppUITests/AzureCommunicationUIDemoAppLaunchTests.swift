//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppLaunchTests: XCUITestBase {

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app?.launch()
    }

    func testCallCompositeLaunch() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        tapButton(buttonName: "Join call", shouldWait: true)
    }

    func testCallCompositeExit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }
        tapInterfaceFor(.uiKit)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        tapButton(buttonName: "Join call", shouldWait: true)
        tapButton(buttonName: "AzureCommunicationUI.CallingView.ControlButton.HangUp", shouldWait: true)
        tapButton(buttonName: "Leave call", shouldWait: true)
    }

    func testCallCompositeWithExpiredToken() {
        // UI tests must launch the application that they test.
        guard let app = app else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapButton(buttonName: "textFieldClearButton", shouldWait: false)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: getExpiredToken(), application: app)

        tapButton(buttonName: "Start Experience", shouldWait: true)
        tapButton(buttonName: "Join call", shouldWait: true)

        let leaveCallButton = app.buttons["AzureCommunicationUI.CallingView.PrimaryButton.LeaveCall"]
        wait(for: leaveCallButton)
        leaveCallButton.tap()
    }
    func testCallCompositeJoinCallGroupCallSwiftUI() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(buttonName: "Join call", shouldWait: true)
        tapButton(buttonName: "AzureCommunicationUI.CallingView.ControlButton.HangUp", shouldWait: true)
        tapButton(buttonName: "Leave call", shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallSwiftUI() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(buttonName: "Join call", shouldWait: true)
        tapButton(buttonName: "AzureCommunicationUI.CallingView.ControlButton.HangUp", shouldWait: true)
        tapButton(buttonName: "Leave call", shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(buttonName: "Join call", shouldWait: true)
        tapButton(buttonName: "AzureCommunicationUI.CallingView.ControlButton.HangUp", shouldWait: true)
        tapButton(buttonName: "Leave call", shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(buttonName: "Start Experience", shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(buttonName: "Join call", shouldWait: true)
        tapButton(buttonName: "AzureCommunicationUI.CallingView.ControlButton.HangUp", shouldWait: true)
        tapButton(buttonName: "Leave call", shouldWait: true)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    // MARK: Private / helper functions

    /// Toggles the control views in the setup screen
    private func toggleSetupScreenControlButtons() {
        guard let app = app else {
            XCTFail("No App launch")
            return
        }

        let videoOffButton = app.buttons["Video off"]
        let videoOnButton = app.buttons["Video on"]

        // test video button
        if videoOffButton.waitForExistence(timeout: 3) {
            videoOffButton.tap()
        } else if videoOnButton.waitForExistence(timeout: 3) {
            videoOnButton.tap()
        }

        // test mic button
        let micOffButton = app.buttons["Mic off"]
        let micOnButton = app.buttons["Mic on"]
        if micOffButton.waitForExistence(timeout: 3) {
            micOffButton.tap()
        } else if micOnButton.waitForExistence(timeout: 3) {
            micOnButton.tap()
        }

        // test audio drawer
        tapEnabledButton(buttonName: "Speaker", shouldWait: true)
        app.tables.cells.firstMatch.tap()
        tapEnabledButton(buttonName: "iPhone", shouldWait: true)
        app.tables.firstMatch.swipeDown()
    }

}

extension AzureCommunicationUIDemoAppLaunchTests {
    private func getExpiredToken() -> String {
        guard let infoDict = Bundle(for: AzureCommunicationUIDemoAppLaunchTests.self).infoDictionary,
              let value = infoDict["expiredAcsToken"] as? String, !value.isEmpty else {
                  XCTFail("Need to set expiredAcsToken value in AppConfig")
            return ""
        }
        return value
    }
}

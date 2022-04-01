//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppUITests: XCUITestBase {
    private var app: XCUIApplication?

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app?.launch()
    }

    func testCallCompositeLaunch() {
        guard let app = app else {
            XCTFail("No App launch")
            return
        }

        app.buttons["UI Kit"].tap()

        let startButton = app.buttons["Start Experience"]
        waitEnabled(for: startButton)

        startButton.tap()

        let joinButton = app.buttons["Join call"]
        wait(for: joinButton)
        joinButton.tap()
    }

    func testCallCompositeExit() {
        guard let app = app else {
            XCTFail("No App launch")
            return
        }

        app.buttons["UI Kit"].tap()

        let startButton = app.buttons["Start Experience"]
        waitEnabled(for: startButton)

        startButton.tap()

        let joinButton = app.buttons["Join call"]
        wait(for: joinButton)
        joinButton.tap()

        let hangUpButton = app.buttons["AzureCommunicationUI.CallingView.ControlButton.HangUp"]
        wait(for: hangUpButton)
        hangUpButton.tap()

        let leaveCallButton = app.buttons["Leave call"]
        wait(for: leaveCallButton)
        leaveCallButton.tap()

    }

    func testCallCompositeWithExpiredToken() {
        // UI tests must launch the application that they test.
        guard let app = app else {
            XCTFail("No App launch")
            return
        }

        app.buttons["Swift UI"].tap()

        let deleteTokenButton = app.buttons["textFieldClearButton"]
        deleteTokenButton.tap()

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: getExpiredToken(), application: app)

        let startButton = app.buttons["Start Experience"]
        waitEnabled(for: startButton)

        startButton.tap()

        let joinButton = app.buttons["Join call"]
        wait(for: joinButton)
        joinButton.tap()
    }

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

}

extension AzureCommunicationUIDemoAppUITests {
    private func getExpiredToken() -> String {
        guard let infoDict = Bundle(for: AzureCommunicationUIDemoAppUITests.self).infoDictionary,
              let value = infoDict["expiredAcsToken"] as? String else {
            return ""
        }
        return value
    }
}

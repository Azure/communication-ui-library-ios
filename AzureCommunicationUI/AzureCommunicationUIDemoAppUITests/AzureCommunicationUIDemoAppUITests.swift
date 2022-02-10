//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppUITests: XCUITestBase {
    func testCallCompositeLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.buttons["UI Kit"].tap()

        let startButton = app.buttons["Start Experience"]
        waitEnabled(for: startButton)

        startButton.tap()

        let joinButton = app.buttons["Join Call"]
        wait(for: joinButton)
        joinButton.tap()
    }

    func testCallCompositeExit() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.buttons["UI Kit"].tap()

        let startButton = app.buttons["Start Experience"]
        waitEnabled(for: startButton)

        startButton.tap()

        let joinButton = app.buttons["Join Call"]
        wait(for: joinButton)
        joinButton.tap()

        let hangUpButton = app.buttons["HangUpButton"]
        wait(for: hangUpButton)
        hangUpButton.tap()

        let leaveCallButton = app.buttons["Leave call"]
        wait(for: leaveCallButton)
        leaveCallButton.tap()

    }

    func testCallCompositeWithExpiredToken() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.buttons["Swift UI"].tap()

        let deleteTokenButton = app.buttons["textFieldClearButton"]
        deleteTokenButton.tap()

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: getExpiredToken(), application: app)

        let startButton = app.buttons["Start Experience"]
        waitEnabled(for: startButton)

        startButton.tap()

        let joinButton = app.buttons["Join Call"]
        wait(for: joinButton)
        joinButton.tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
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

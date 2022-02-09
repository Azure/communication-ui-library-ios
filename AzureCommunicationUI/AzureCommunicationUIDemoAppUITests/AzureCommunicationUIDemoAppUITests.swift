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

        wait(for:startButton)

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
        return "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMyIsIng1dCI6Ikc5WVVVTFMwdlpLQTJUNjFGM1dzYWdCdmFMbyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjcxZWM1OTBiLWNiYWQtNDkwYy05OWM1LWI1NzhiZGFjZGU1NF8wMDAwMDAwZS01ZmRhLWQ0ZTQtMjhmNC0zNDNhMGQwMDdmYTMiLCJzY3AiOjE3OTIsImNzaSI6IjE2Mzk2MDMzMTkiLCJleHAiOjE2Mzk2ODk3MTksImFjc1Njb3BlIjoidm9pcCIsInJlc291cmNlSWQiOiI3MWVjNTkwYi1jYmFkLTQ5MGMtOTljNS1iNTc4YmRhY2RlNTQiLCJpYXQiOjE2Mzk2MDMzMTl9.j-S73eJp_vruYcGmJNWGO6ydW2G3vLmPV562lRkv1lb-mkzfOtRpPpTHpFUyCE53T6ddNE1GJRacsE9wVw3_5bVkiTpkPLSzly4NP06V8PWJ63l81JewKaABcIYwHfIWFBe3SxKGoCA-dRuAf59bgiSNl1NCIARYWW2jselKeXIQ6oOkGq4UTfCAx02swNnpR-Eo9DnmU6XRoQ5-9ZZ-E8Ckteb5ukxb55LNA7-MT9JrgzIIPYbMO4uOv7mNptuaiRHprXui9ve_R-hTRMCQ9i7vPbsRQl3mYHfo8ooidkydcUybnP-vTdQvE1KXGZ7WogSGg1EuLYrT1o1iXpHn2g"
    }
}


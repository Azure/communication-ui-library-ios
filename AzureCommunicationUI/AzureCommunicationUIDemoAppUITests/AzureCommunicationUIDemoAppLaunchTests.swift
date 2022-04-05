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
    }

    func testCallCompositeExit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }
        tapInterfaceFor(.uiKit)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .leaveCallAccssibilityLabel, shouldWait: true)
    }

    func testCallCompositeWithExpiredToken() {
        // UI tests must launch the application that they test.
        guard let app = app else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapButton(accessibilityIdentifier: .clearTokenTextFieldAccessibilityLabel, shouldWait: false)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: getExpiredToken(), application: app)

        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallSwiftUI() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .leaveCallAccssibilityLabel, shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallSwiftUI() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .leaveCallAccssibilityLabel, shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .leaveCallAccssibilityLabel, shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallUIKit() {
        guard app != nil else {
            XCTFail("No App launch")
            return
        }

        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        toggleSetupScreenControlButtons()
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .leaveCallAccssibilityLabel, shouldWait: true)
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

        // test video button
        tapButton(accessibilityIdentifier: .toggleVideoAccessibilityID, shouldWait: true)

        // test mic button
        tapButton(accessibilityIdentifier: .togglMicAccessibilityID, shouldWait: true)

        // test audio drawer
        tapButton(accessibilityIdentifier: .deviceAccesibiiltyLabel, shouldWait: true)
        app.tables.cells.firstMatch.tap()
        tapButton(accessibilityIdentifier: .deviceAccesibiiltyLabel, shouldWait: true)
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

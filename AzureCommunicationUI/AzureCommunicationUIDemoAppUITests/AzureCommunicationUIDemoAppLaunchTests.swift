//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppLaunchTests: XCUITestBase {

    func testCallCompositeLaunch() {
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
        leaveCall()
    }

    func testCallCompositeWithExpiredToken() {
        tapInterfaceFor(.swiftUI)
        tapButton(accessibilityIdentifier: .clearTokenTextFieldAccessibilityLabel, shouldWait: false)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: getExpiredToken(), application: app)

        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        leaveCall()
    }

    func testCallCompositeJoinCallTeamsCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        leaveCall()
    }

    func testCallCompositeJoinCallGroupCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        leaveCall()
    }

    func testCallCompositeJoinCallTeamsCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
        leaveCall()
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

    /// Toggles the leave call overlay  in the calling screen
    private func leaveCall() {
        app.tables.cells.firstMatch.tap()
        XCTAssertTrue(app.buttons[LocalizationKey.startExperienceAccessibilityLabel.rawValue]
                        .waitForExistence(timeout: 3))
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

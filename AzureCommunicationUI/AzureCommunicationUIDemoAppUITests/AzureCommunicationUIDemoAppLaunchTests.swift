//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppLaunchTests: XCUITestBase {

    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
    }

    func testCallCompositeLaunch() {
        tapInterfaceFor(.uiKit)
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
    }

    func testCallCompositeJoinCallTeamsCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(accessibilityIdentifier: .startExperienceAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .joinCallAccessibilityLabel, shouldWait: true)
        tapButton(accessibilityIdentifier: .hangupAccessibilityLabel, shouldWait: true)
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

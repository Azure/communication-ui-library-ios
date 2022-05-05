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
        tapButton(
            accessibilityIdentifier: AccessibilityId.clearTokenTextFieldAccessibilityID.rawValue,
            shouldWait: false)

        let acsTokenTextField = app.textFields["ACS Token"]
        acsTokenTextField.setText(text: getExpiredToken(), application: app)

        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue, shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallSwiftUI() {
        tapInterfaceFor(.swiftUI)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
    }

    func testCallCompositeJoinCallGroupCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
    }

    func testCallCompositeJoinCallTeamsCallUIKit() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.teamsCall)
        tapEnabledButton(
            accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
            shouldWait: true)
        tapButton(
            accessibilityIdentifier: AccessibilityIdentifier.hangupAccessibilityID.rawValue,
            shouldWait: true)
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

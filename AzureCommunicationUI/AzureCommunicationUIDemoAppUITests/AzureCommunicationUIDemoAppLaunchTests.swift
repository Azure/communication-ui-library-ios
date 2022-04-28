//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppLaunchTests: XCUITestBase {

    func testLaunch() {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
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

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
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

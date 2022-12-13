//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppLaunchTests: XCUITestBase {
    func testCallCompositeSwiftUILaunch() {
        tapInterfaceFor(.swiftUI)
        startApp()
    }

    func testCallCompositeUIKitLaunch() {
        tapInterfaceFor(.uiKit)
        startApp()
    }
}

extension AzureCommunicationUIDemoAppLaunchTests {
    func startApp() {
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        wait(for: app.buttons[AccessibilityIdentifier.joinCallAccessibilityID.rawValue])
    }
}

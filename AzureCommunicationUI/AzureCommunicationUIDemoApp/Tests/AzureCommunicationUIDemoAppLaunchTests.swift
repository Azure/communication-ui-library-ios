//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class AzureCommunicationUIDemoAppLaunchTests: XCUITestBase {
    func testCallCompositeSwiftUILaunch() {
        tapInterfaceFor(.callSwiftUI)
        startApp()
    }

    func testCallCompositeUIKitLaunch() {
        tapInterfaceFor(.callUIKit)
        startApp()
    }
}

extension AzureCommunicationUIDemoAppLaunchTests {
    func startApp() {
        startExperience()
        wait(for: app.buttons[AccessibilityIdentifier.joinCallAccessibilityID.rawValue])
    }
}

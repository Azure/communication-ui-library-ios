//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppCallDiagnosticsTests: XCUITestBase {
    func testCallCompositePresentBottomToastAndDismissAfterInterval() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "emitNetworkDiagnosticBad-AID")

        let bottomToastView = app.staticTexts[
            AccessibilityIdentifier.callDiagnosticBottomToastAccessibilityID.rawValue]
        wait(for: bottomToastView)

        XCTAssertTrue(bottomToastView.exists)

        // Asserts that it dismissed after interval
        let predicate = NSPredicate(format: "exists == false")
        let expectation = expectation(for: predicate, evaluatedWith: bottomToastView, handler: nil)
        wait(for: [expectation], timeout: 10.0)
    }

    func testCallCompositePresentNetworkDiagnosticBottomToastAndDismiss() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "emitNetworkDiagnosticBad-AID")

        let bottomToastView = app.staticTexts[
            AccessibilityIdentifier.callDiagnosticBottomToastAccessibilityID.rawValue]
        wait(for: bottomToastView)

        XCTAssertTrue(bottomToastView.exists)

        tapButton(accessibilityIdentifier: "emitNetworkDiagnosticGood-AID")

        XCTAssertFalse(bottomToastView.exists)
    }

    func testCallCompositePresentMediaDiagnosticBottomToastAndDismiss() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "emitMediaDiagnosticBad-AID")

        let bottomToastView = app.staticTexts[
            AccessibilityIdentifier.callDiagnosticBottomToastAccessibilityID.rawValue]
        wait(for: bottomToastView)

        XCTAssertTrue(bottomToastView.exists)

        tapButton(accessibilityIdentifier: "emitMediaDiagnosticGood-AID")

        XCTAssertFalse(bottomToastView.exists)
    }

    func testCallCompositePresentMediaDiagnosticMessageTopBar() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        tapButton(accessibilityIdentifier: "changeMediaDiagnostic-AID")
        tapButton(accessibilityIdentifier: "changeMediaDiagnostic-AID")
        tapButton(accessibilityIdentifier: "changeMediaDiagnostic-AID")

        tapButton(accessibilityIdentifier: "emitMediaDiagnosticBad-AID")

        let messageBarView = app.staticTexts[
            AccessibilityIdentifier.callDiagnosticMessageBarAccessibilityID.rawValue]
        wait(for: messageBarView)

        XCTAssertTrue(messageBarView.exists)

        tapButton(accessibilityIdentifier: "emitMediaDiagnosticGood-AID")

        XCTAssertFalse(messageBarView.exists)
    }

    func testCallCompositePresentMediaDiagnosticMessageTopBarDismiss() {
        tapInterfaceFor(.callUIKit)
        startExperience()

        joinCall()

        wait(for: app.buttons[AccessibilityIdentifier.hangupAccessibilityID.rawValue])

        // Jump to the first media diagnostic that presents a message bar. Which is 4th on mock list.
        tapButton(accessibilityIdentifier: "changeMediaDiagnostic-AID")
        tapButton(accessibilityIdentifier: "changeMediaDiagnostic-AID")
        tapButton(accessibilityIdentifier: "changeMediaDiagnostic-AID")

        tapButton(accessibilityIdentifier: "emitMediaDiagnosticBad-AID")

        let messageBarView = app.staticTexts[AccessibilityIdentifier.callDiagnosticMessageBarAccessibilityID.rawValue]
        wait(for: messageBarView)

        XCTAssertTrue(messageBarView.exists)

        app.buttons[
            AccessibilityIdentifier.callDiagnosticMessageBarAccessibilityID.rawValue].tap()

        XCTAssertFalse(messageBarView.exists)
    }
}

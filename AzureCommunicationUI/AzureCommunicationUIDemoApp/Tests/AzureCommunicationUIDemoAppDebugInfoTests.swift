//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppDebugInfoTests: XCUITestBase {
    func testCallCompositeShareDiagnosticInfo() {
        startCall()
        openShareDiagnosticsInfoMenu()
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popoverDismissRegion = app.otherElements["PopoverDismissRegion"]
            wait(for: popoverDismissRegion)
            popoverDismissRegion.tap()
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            tapButton(accessibilityIdentifier: AccessibilityIdentifier.activityViewControllerCloseButtonAccessibilityID.rawValue)
        }
        checkActivityViewControllerDismissed()
    }

    func testCallCompositeCopyDiagnosticInfo() {
        startCall()
        openShareDiagnosticsInfoMenu()
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.activityViewControllerCopyButtonAccessibilityID.rawValue)
        checkActivityViewControllerDismissed()
    }

    func testCallCompositeSupportForm() {
        startCall()
        openSupportFormDiagnosticsInfoMenu()
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.supportFormTextFieldAccessibilityId.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.supportFormSubmitAccessibilityId.rawValue)
        hangupCall()

        let userReportedOutput = app.staticTexts[AccessibilityId.userReportedIssueAccessibilityID.rawValue]
        wait(for: userReportedOutput)
        XCTAssertTrue(userReportedOutput.exists)
        XCTAssertEqual(userReportedOutput.label, "Sample Message", "The user reported output does not match the expected text.")
    }
}

extension AzureCommunicationUIDemoAppDebugInfoTests {
    func startCall() {
        tapInterfaceFor(.callSwiftUI)
        tapMeetingType(.groupCall)

        startExperience()
        joinCall()
    }

    func openShareDiagnosticsInfoMenu() {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.moreAccessibilityID.rawValue,
                  shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue)
        wait(for: app.otherElements[AccessibilityIdentifier.activityViewControllerAccessibilityID.rawValue])
    }

    func openSupportFormDiagnosticsInfoMenu() {
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.moreAccessibilityID.rawValue,
                  shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue)
        wait(for: app.buttons[AccessibilityIdentifier.supportFormTextFieldAccessibilityId.rawValue])
    }

    func checkActivityViewControllerDismissed() {
        let activityListView = app.otherElements[AccessibilityIdentifier.activityViewControllerAccessibilityID.rawValue]
        let isDismissedPredicate = NSPredicate(format: "exists == false")
        let expectation = expectation(for: isDismissedPredicate,
                                      evaluatedWith: activityListView) {
            return true
        }
        wait(for: [expectation], timeout: 20.0)
    }
}

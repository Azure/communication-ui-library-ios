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

// Disabled until able to fix TextField
//    func testCallCompositeSupportForm() {
//        startCall()
//        openSupportFormDiagnosticsInfoMenu()
//        enterText(accessibilityIdentifier: AccessibilityIdentifier.supportFormTextFieldAccessibilityId.rawValue, text: "Test Message")
//        tapButton(accessibilityIdentifier: AccessibilityIdentifier.supportFormSubmitAccessibilityId.rawValue)
//    }
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
        // wait(for: app.textFields[AccessibilityIdentifier.supportFormTextFieldAccessibilityId.rawValue])
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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class AzureCommunicationUIDemoAppDebugInfoTests: XCUITestBase {
    func testCallCompositeShareDiagnosticInfo() throws {
        try startCall()
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

    func testCallCompositeCopyDiagnosticInfo() throws {
        try startCall()
        openShareDiagnosticsInfoMenu()
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.activityViewControllerCopyButtonAccessibilityID.rawValue)
        checkActivityViewControllerDismissed()
    }
}

extension AzureCommunicationUIDemoAppDebugInfoTests {
    func startCall() throws {
        try skipTestIfNeeded()
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

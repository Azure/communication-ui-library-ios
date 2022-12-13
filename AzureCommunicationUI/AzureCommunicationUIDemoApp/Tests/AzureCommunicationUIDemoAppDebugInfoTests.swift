//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

 class AzureCommunicationUIDemoAppDebugInfoTests: XCUITestBase {
    func testCallCompositeShareDiagnosticInfo() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.groupCall)
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                  shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.moreAccessibilityID.rawValue,
                  shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                shouldWait: true)
        wait(for: app.otherElements[AccessibilityIdentifier.activityViewControllerAccessibilityID.rawValue])
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popoverDismissRegion = app.otherElements["PopoverDismissRegion"]
            wait(for: popoverDismissRegion)
            popoverDismissRegion.tap()
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            tapButton(accessibilityIdentifier: AccessibilityIdentifier.activityViewControllerCloseButtonAccessibilityID.rawValue,
                      shouldWait: true)
        }
        checkActivityViewControllerDismissed()
    }

    func testCallCompositeCopyDiagnosticInfo() {
        tapInterfaceFor(.uiKit)
        tapMeetingType(.groupCall)
        tapButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                  shouldWait: true)
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.moreAccessibilityID.rawValue,
                  shouldWait: true)
        tapCell(accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                shouldWait: true)
        wait(for: app.otherElements[AccessibilityIdentifier.activityViewControllerAccessibilityID.rawValue])
        tapButton(accessibilityIdentifier: AccessibilityIdentifier.activityViewControllerCopyButtonAccessibilityID.rawValue,
                  shouldWait: true)
        checkActivityViewControllerDismissed()
    }
 }

 extension AzureCommunicationUIDemoAppDebugInfoTests {
    func checkActivityViewControllerDismissed() {
        let activityListView = app.otherElements[AccessibilityIdentifier.activityViewControllerAccessibilityID.rawValue]
        let isDismissedPredicate = NSPredicate(format: "exists == 0")
        let expectation = expectation(for: isDismissedPredicate,
                                      evaluatedWith: activityListView) {
            return true
        }
        wait(for: [expectation], timeout: 10.0)
    }
 }

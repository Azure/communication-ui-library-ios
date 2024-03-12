//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class SupportFormViewModelTests: XCTestCase {
    func test_SupportFormViewModel_ValidateStrings() {
        let events = CallComposite.Events()
        let debugInfo = DebugInfo(
            callHistoryRecords: [],
            callingUIVersion: "1.0",
            logFiles: [])
        // Initialize the viewModel with mocks
        let viewModel = SupportFormViewModel(
            dispatchAction: { _ in },
            events: events,
            localizationProvider: LocalizationProviderMocking(),
            getDebugInfo: { debugInfo })
        // Verify the viewModel properties against expected localization keys
        XCTAssertEqual(viewModel.reportIssueTitle, "AzureCommunicationUICalling.ReportIssue.Title")
        XCTAssertEqual(viewModel.logsAttachNotice, "AzureCommunicationUICalling.LogsAttach.Notice")
        XCTAssertEqual(viewModel.privacyPolicyText, "AzureCommunicationUICalling.PrivacyPolicy.Text")
        XCTAssertEqual(viewModel.describeYourIssueHintText, "AzureCommunicationUICalling.DescribeYourIssueHint.Text")
        XCTAssertEqual(viewModel.cancelButtonText, "AzureCommunicationUICalling.CancelButton.Text")
        XCTAssertEqual(viewModel.reportAProblemText, "AzureCommunicationUICalling.ReportAProblem.Text")
        XCTAssertEqual(viewModel.sendFeedbackText, "AzureCommunicationUICalling.SendFeedback.Text")
    }

    func test_SupportFormViewModel_ValidateSendFormTriggersEvent() {
        let events = CallComposite.Events()
        var lastIssue: CallCompositeUserReportedIssue?
        var lastAction: Action?
        events.onUserReportedIssue = { issue in
            lastIssue = issue
        }
        let debugInfo = DebugInfo(
            callHistoryRecords: [], callingUIVersion: "1.0", logFiles: []
        )
        let dispatchAction: ActionDispatch = { action in
            lastAction = action
        }
        // Initialize the viewModel with mocks
        let viewModel = SupportFormViewModel(
            dispatchAction: dispatchAction,
            events: events,
            localizationProvider: LocalizationProviderMocking(),
            getDebugInfo: { debugInfo })
        viewModel.messageText = "TEST MESSAGE"
        viewModel.sendReport()
        XCTAssertTrue(lastIssue != nil)
        XCTAssertEqual(lastIssue?.userMessage, "TEST MESSAGE")
        XCTAssertTrue(lastAction == Action.hideSupportForm)
    }

    func test_SupportFormViewModel_ValidateSendFormTriggersEventNoText() {
        let events = CallComposite.Events()
        let debugInfo = DebugInfo(
            callHistoryRecords: [], callingUIVersion: "1.0", logFiles: []
        )
        // Initialize the viewModel with mocks
        let viewModel = SupportFormViewModel(
            dispatchAction: { _ in },
            events: events,
            localizationProvider: LocalizationProviderMocking(),
            getDebugInfo: { debugInfo })
        viewModel.messageText = ""
        XCTAssertTrue(viewModel.blockSubmission)
    }
}

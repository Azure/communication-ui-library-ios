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
            callHistoryRecords: [], callingUIVersion: "1.0", logFiles: []
        )
        // Initialize the viewModel with mocks
        let viewModel = SupportFormViewModel(events: events,
                                             localizationProvider: LocalizationProviderMocking(),
                                             getDebugInfo: { debugInfo })
        // Verify the viewModel properties against expected localization keys
        XCTAssertEqual(viewModel.reportIssueTitle, "AzureCommunicationUICalling.ReportIssue.Title")
        XCTAssertEqual(viewModel.logsAttachNotice, "AzureCommunicationUICalling.LogsAttach.Notice")
        XCTAssertEqual(viewModel.privacyPolicyText, "AzureCommunicationUICalling.PrivacyPolicy.Text")
        XCTAssertEqual(viewModel.describeYourIssueHintText, "AzureCommunicationUICalling.DescribeYourIssueHint.Text")
        XCTAssertEqual(viewModel.cancelButtonText, "AzureCommunicationUICalling.CancelButton.Text")
        XCTAssertEqual(viewModel.attachScreenshot, "AzureCommunicationUICalling.Attach.Screenshot")
        XCTAssertEqual(viewModel.reportAProblemText, "AzureCommunicationUICalling.ReportAProblem.Text")
        XCTAssertEqual(viewModel.sendFeedbackText, "AzureCommunicationUICalling.SendFeedback.Text")
    }
}

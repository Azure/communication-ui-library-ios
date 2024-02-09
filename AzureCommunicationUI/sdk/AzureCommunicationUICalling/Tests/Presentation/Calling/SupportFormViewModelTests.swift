//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class SupportFormViewModelTests: XCTestCase {
    func test_SupportFormViewModel_InitializesWithLocalizedStringsAndDefaultValues() {
        let events = CallComposite.Events()
        let debugInfo = DebugInfo(
            callHistoryRecords: [], callingUIVersion: "1.0", logFiles: []
        )
        // Initialize the viewModel with mocks
        let viewModel = SupportFormViewModel(events: events,
                                             localizationProvider: LocalizationProviderMocking(),
                                             getDebugInfo: { debugInfo })
        XCTAssertEqual(viewModel.reportIssueTitle, "Localized reportIssueTitle")

    }

}

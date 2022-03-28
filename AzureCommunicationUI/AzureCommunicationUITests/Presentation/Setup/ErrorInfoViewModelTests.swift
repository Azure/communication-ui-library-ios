//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUI

class ErrorInfoViewModelTests: XCTestCase {
    private var storeFactory: StoreFactoryMocking!
    private var localizationProvier: LocalizationProviderMocking!
    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        localizationProvier = LocalizationProviderMocking()
    }

    func test_dismissContent_alwaysReturns_snackBarDismissCintent() {
        let sut = makeSUT()

        XCTAssertEqual(sut.dismissContent, "AzureCommunicationUI.SnackBar.Button.Dismiss")
    }

    func test_errorCodeCallJoin_returns_snackBarErrorJoinCallMessage() {
        let sut = makeSUT()
        let event = ErrorEvent(code: CallCompositeErrorCode.callJoin)
        let state = ErrorState(error: event, errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.message, "AzureCommunicationUI.SnackBar.Text.ErrorCallJoin")
    }

    func test_errorCodeCallEnd_returns_snackBarErrorCallEndMessage() {
        let sut = makeSUT()
        let event = ErrorEvent(code: CallCompositeErrorCode.callEnd)
        let state = ErrorState(error: event, errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.message, "AzureCommunicationUI.SnackBar.Text.ErrorCallEnd")
    }

    func makeSUT() -> ErrorInfoViewModel {
        return ErrorInfoViewModel(localizationProvider: localizationProvier)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUI

class ErrorInfoViewModelTests: XCTestCase {
    private var localizationProvier: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvier = LocalizationProviderMocking()
    }

    func test_errorInfoViewModel_dismissContent_alwaysReturns_snackBarDismissContent() {
        let sut = makeSUT()

        XCTAssertEqual(sut.dismissContent, "AzureCommunicationUI.SnackBar.Button.Dismiss")
    }

    func test_errorInfoViewModel_update_when_errorStateCallJoinSet_then_snackBarErrorJoinCallMessageDisplayed() {
        let sut = makeSUT()
        let event = ErrorEvent(code: CallCompositeErrorCode.callJoin)
        let state = ErrorState(error: event, errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.message, "AzureCommunicationUI.SnackBar.Text.ErrorCallJoin")
    }

    func test_errorInfoViewModel_update_when_errorStateCallEnd_then_snackBarErrorCallEndMessage() {
        let sut = makeSUT()
        let event = ErrorEvent(code: CallCompositeErrorCode.callEnd)
        let state = ErrorState(error: event, errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.message, "AzureCommunicationUI.SnackBar.Text.ErrorCallEnd")
    }

    func test_errorInfoViewModel_update_when_errorTypeIsEmpty_then_isDisplayEqualFalse() {
        let sut = makeSUT()
        let event = ErrorEvent(code: CallCompositeErrorCode.callJoin)
        let state = ErrorState(error: event, errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)

        let newState = ErrorState(error: nil, errorCategory: .callState)
        sut.update(errorState: newState)
        XCTAssertEqual(sut.isDisplayed, false)
    }

    func makeSUT() -> ErrorInfoViewModel {
        return ErrorInfoViewModel(localizationProvider: localizationProvier)
    }
}

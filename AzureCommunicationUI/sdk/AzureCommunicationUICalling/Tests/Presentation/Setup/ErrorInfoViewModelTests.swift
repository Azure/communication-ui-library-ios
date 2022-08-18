//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class ErrorInfoViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
    }

    func test_errorInfoViewModel_dismissContent_alwaysReturns_snackBarDismissContent() {
        let sut = makeSUT()

        XCTAssertEqual(sut.dismissContent, "AzureCommunicationUICalling.SnackBar.Button.Dismiss")
    }

    func test_errorInfoViewModel_update_when_errorStateCallJoinSet_then_snackBarErrorJoinCallMessageDisplayed() {
        let sut = makeSUT()
        let state = ErrorState(internalError: .callJoinFailed,
                               error: nil,
                               errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.title, "AzureCommunicationUICalling.SnackBar.Text.ErrorCallJoin")
    }

    func test_errorInfoViewModel_update_when_errorStateCallEnd_then_snackBarErrorCallEndMessage() {
        let sut = makeSUT()
        let state = ErrorState(internalError: .callEndFailed,
                               error: nil,
                               errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.title, "AzureCommunicationUICalling.SnackBar.Text.ErrorCallEnd")
    }

    func test_errorInfoViewModel_update_when_errorStateCallEvictionSet_then_snackBarErrorCallEvictedMessageDisplayed() {
        let sut = makeSUT()
        let state = ErrorState(internalError: .callEvicted,
                               error: nil,
                               errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.title, "AzureCommunicationUICalling.SnackBar.Text.ErrorCallEvicted")
    }

    func test_errorInfoViewModel_update_when_errorStateCallDeniedSet_then_snackBarErrorCallDeniedMessageDisplayed() {
        let sut = makeSUT()
        let state = ErrorState(internalError: .callDenied,
                               error: nil,
                               errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.title, "AzureCommunicationUICalling.SnackBar.Text.ErrorCallDenied")
    }

    func test_errorInfoViewModel_update_when_errorTypeIsEmpty_then_isDisplayEqualFalse() {
        let sut = makeSUT()
        let state = ErrorState(internalError: .callJoinFailed,
                               error: nil,
                               errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)

        let newState = ErrorState(error: nil, errorCategory: .callState)
        sut.update(errorState: newState)
        XCTAssertEqual(sut.isDisplayed, false)
    }

    func test_errorInfoViewModel_update_when_errorStateCameraOnFailedSet_then_snackBarErrorCameraOnFailedMessageDisplayed() {
        let sut = makeSUT()
        let state = ErrorState(internalError: .cameraOnFailed,
                               error: nil,
                               errorCategory: .callState)

        sut.update(errorState: state)
        XCTAssertEqual(sut.isDisplayed, true)
        XCTAssertEqual(sut.title, "AzureCommunicationUICalling.SnackBar.Text.CameraOnFailed")
    }

    func makeSUT() -> ErrorInfoViewModel {
        return ErrorInfoViewModel(localizationProvider: localizationProvider)
    }
}

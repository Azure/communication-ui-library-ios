//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class ErrorReducerTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func test_handleErrorReducer_reduce_when_notErrorState_then_return() {
        let state = StateMocking()
        let action = ErrorAction.FatalErrorUpdated(error: CommunicationUIErrorEvent(code: "",
                                                                     error: nil))
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssert(resultState is StateMocking)
    }

    func test_handleErrorReducer_reduce_when_fatalErrorUpdated_then_returnErrorState_categoryFatal() {
        let state = ErrorState(error: CommunicationUIErrorEvent(code: CallCompositeErrorCode.callJoin,
                                                 error: nil),
                               errorCategory: .callState)
        let errorEvent = CommunicationUIErrorEvent(code: CallCompositeErrorCode.callJoin, error: nil)

        let action = ErrorAction.FatalErrorUpdated(error: errorEvent)
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssertTrue(resultState is ErrorState)
        guard let errorState = resultState as? ErrorState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(errorState.error?.code, errorEvent.code)
        XCTAssertEqual(errorState.errorCategory, .fatal)
    }

    func test_handleErrorReducer_reduce_when_statusErrorAndCallReset_then_returnErrorState_categoryCallState() {
        let state = ErrorState(error: CommunicationUIErrorEvent(code: CallCompositeErrorCode.callJoin,
                                                 error: nil),
                               errorCategory: .callState)
        let errorEvent = CommunicationUIErrorEvent(code: CallCompositeErrorCode.callJoin, error: nil)

        let action = ErrorAction.StatusErrorAndCallReset(error: errorEvent)
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssertTrue(resultState is ErrorState)
        guard let errorState = resultState as? ErrorState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(errorState.error?.code, errorEvent.code)
        XCTAssertEqual(errorState.errorCategory, .callState)

    }

    func test_handleErrorReducer_reduce_when_statusErrorCallEvictionAndCallReset_then_returnErrorState_categoryCallState() {
        let state = ErrorState(error: CommunicationUIErrorEvent(code: CallCompositeErrorCode.callEvicted,
                                                 error: nil),
                               errorCategory: .callState)
        let errorEvent = CommunicationUIErrorEvent(code: CallCompositeErrorCode.callEvicted, error: nil)

        let action = ErrorAction.StatusErrorAndCallReset(error: errorEvent)
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssertTrue(resultState is ErrorState)
        guard let errorState = resultState as? ErrorState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(errorState.error?.code, errorEvent.code)
        XCTAssertEqual(errorState.errorCategory, .callState)
    }

    func test_handleErrorReducer_reduce_when_callStartRequested_then_cleanup() {
        let error = CommunicationUIErrorEvent(code: "", error: nil)
        let state = ErrorState(error: error,
                               errorCategory: .callState)

        let action = CallingAction.CallStartRequested()
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssertTrue(resultState is ErrorState)
        guard let errorState = resultState as? ErrorState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(errorState.error, nil)
        XCTAssertEqual(errorState.errorCategory, .none)

    }
}

extension ErrorReducerTests {
    private func getSUT() -> ErrorReducer {
        return ErrorReducer()
    }
}

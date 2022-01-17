//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class ErrorReducerTests: XCTestCase {
    override func setUp() { }

    func test_handleErrorReducer_reduce_when_notErrorState_then_return() {
        let state = StateMocking()
        let action = ErrorAction.FatalErrorUpdated(error: ErrorEvent(code: "",
                                                                     error: nil))
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssert(resultState is StateMocking)
    }

    func test_handleErrorReducer_reduce_when_fatalErrorUpdated_then_returnErrorState() {
        let state = ErrorState(error: nil, errorCode: CallCompositeErrorCode.callJoin, errorCategory: .callState)
        let error = ErrorEvent(code: CallCompositeErrorCode.callJoin, error: nil)

        let action = ErrorAction.FatalErrorUpdated(error: error)
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssertTrue(resultState is ErrorState)
        guard let errorState = resultState as? ErrorState else {
            XCTFail()
            return
        }

        XCTAssertEqual(errorState.errorCode, CallCompositeErrorCode.callJoin)
    }

    func test_handleErrorReducer_reduce_when_callingViewLaunched_then_cleanup() {
        let error = ErrorEvent(code: CallCompositeErrorCode.callJoin, error: nil)
        let state = ErrorState(error: error, errorCode: CallCompositeErrorCode.callJoin, errorCategory: .callState)

        let action = CallingViewLaunched()
        let sut = getSUT()

        let resultState = sut.reduce(state, action)
        XCTAssertTrue(resultState is ErrorState)
        guard let errorState = resultState as? ErrorState else {
            XCTFail()
            return
        }

        XCTAssertEqual(errorState.error, nil)
        XCTAssertEqual(errorState.errorCode, "")
        XCTAssertEqual(errorState.errorCategory, .none)

    }
}

extension ErrorReducerTests {
    private func getSUT() -> ErrorReducer {
        return ErrorReducer()
    }
}

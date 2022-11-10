//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class ErrorReducerTests: XCTestCase {

    func test_handleErrorReducer_reduce_when_fatalErrorUpdated_then_returnErrorState_categoryFatal() {
        let state = ErrorState()
        let action = Action.errorAction(.fatalErrorUpdated(internalError: .callJoinFailed,
                                                   error: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .callJoinFailed)
        XCTAssertEqual(resultState.errorCategory, .fatal)
    }

    func test_handleErrorReducer_reduce_when_statusErrorAndCallReset_then_returnErrorState_categoryCallState() {
        let state = ErrorState()
        let action = Action.errorAction(.statusErrorAndCallReset(internalError: .callJoinFailed,
                                                         error: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .callJoinFailed)
        XCTAssertEqual(resultState.errorCategory, .callState)
    }

    func test_handleErrorReducer_reduce_when_statusErrorCallEvictionAndCallReset_then_returnErrorState_categoryCallState() {
        let state = ErrorState()

        let action = Action.errorAction(.statusErrorAndCallReset(internalError: .callEvicted,
                                                         error: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .callEvicted)
        XCTAssertEqual(resultState.errorCategory, .callState)
    }

    func test_handleErrorReducer_reduce_when_statusErrorCallDeniedAndCallReset_then_returnErrorState_categoryCallState() {
        let state = ErrorState()
        let action = Action.errorAction(.statusErrorAndCallReset(internalError: .callDenied,
                                                                  error: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .callDenied)
        XCTAssertEqual(resultState.errorCategory, .callState)
    }

    func test_handleErrorReducer_reduce_when_callStartRequested_then_cleanup() {
        let state = ErrorState(internalError: .callDenied,
                               error: nil,
                               errorCategory: .callState)

        let action = Action.callingAction(.callStartRequested)
        let sut = makeSUT()

        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, nil)
        XCTAssertEqual(resultState.errorCategory, .none)
    }

    func test_handleErrorReducer_reduce_when_cameraOnFailed_then_returnErrorState_categoryCallState() {
        let state = ErrorState()
        let action = Action.localUserAction(.cameraOnFailed(error: CallCompositeInternalError.cameraOnFailed))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .cameraOnFailed)
        XCTAssertEqual(resultState.errorCategory, .callState)
    }
}

extension ErrorReducerTests {
    private func makeSUT() -> Reducer<ErrorState, Action> {
        return .liveErrorReducer
    }
}

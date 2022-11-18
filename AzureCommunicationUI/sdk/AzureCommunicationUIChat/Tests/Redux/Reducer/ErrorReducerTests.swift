//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class ErrorReducerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_handleErrorReducer_reduce_when_fatalErrorUpdated_then_returnErrorState_categoryFatal() {
        let state = ErrorState()
        let action = Action.errorAction(.fatalErrorUpdated(internalError: .chatConnectFailed,
                                                           error: nil))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .chatConnectFailed)
        XCTAssertEqual(resultState.errorCategory, .fatal)
    }

    func test_handleErrorReducer_reduce_when_statusErrorCallEvictionAndCallReset_then_returnErrorState_categoryCallState() {
        let state = ErrorState()
        let action = Action.errorAction(.fatalErrorUpdated(
            internalError: .chatEvicted, error: nil))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .chatEvicted)
        XCTAssertEqual(resultState.errorCategory, .fatal)
    }
}

extension ErrorReducerTests {
    private func getSUT() -> Reducer<ErrorState, Action> {
        return .liveErrorReducer
    }
}

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
        let action = Action.errorAction(.fatalErrorUpdated(internalError: .chatJoinFailed,
                                                           error: nil))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .chatJoinFailed)
        XCTAssertEqual(resultState.errorCategory, .fatal)
    }

    func test_handleErrorReducer_reduce_when_statusErrorChatEvictionAndChatReset_then_returnErrorState_categoryChatState() {
        let state = ErrorState()
        let action = Action.errorAction(.fatalErrorUpdated(
            internalError: .chatEvicted, error: nil))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .chatEvicted)
        XCTAssertEqual(resultState.errorCategory, .fatal)
    }

    func test_handleErrorReducer_reduce_when_statusErrorChatInitFailed_then_returnErrorState_categoryChatState() {
        let state = ErrorState()
        let error = ChatCompositeError(code: "failed to init chat client")
        let action = Action.chatAction(.initializeChatFailed(error: error))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.internalError, .chatJoinFailed)
        XCTAssertEqual(resultState.errorCategory, .fatal)
    }
}

extension ErrorReducerTests {
    private func getSUT() -> Reducer<ErrorState, Action> {
        return .liveErrorReducer
    }
}

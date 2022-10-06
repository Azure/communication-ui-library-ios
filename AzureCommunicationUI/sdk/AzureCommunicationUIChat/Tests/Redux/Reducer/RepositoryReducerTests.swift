//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class RepositoryReducerTests: XCTestCase {

    func test_repositoryReducer_reduce_when_fetchInitialMessagesSuccessAction_then_stateUpdated() {
        let initialTimestamp = Date()
        let state = RepositoryState(lastUpdatedTimestamp: initialTimestamp)
        let action = Action.repositoryAction(.fetchInitialMessagesSuccess(messages: []))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.lastUpdatedTimestamp > initialTimestamp)
    }

    func test_repositoryReducer_reduce_when_chatMessageReceivedAction_then_stateUpdated() {
        let initialTimestamp = Date()
        let state = RepositoryState(lastUpdatedTimestamp: initialTimestamp)
        let action = Action.repositoryAction(.chatMessageReceived(message: ChatMessageInfoModel()))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.lastUpdatedTimestamp > initialTimestamp)
    }
}

extension RepositoryReducerTests {
    func getSUT() -> Reducer<RepositoryState, Action> {
        return .liveRepositoryReducer
    }
}

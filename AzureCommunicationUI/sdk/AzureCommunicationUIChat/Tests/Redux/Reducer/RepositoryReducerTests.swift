//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class RepositoryReducerTests: XCTestCase {

    func test_repositoryReducer_reduce_when_repositoryUpdatedAction_then_stateUpdated() {
        let initialTimestamp = Date()
        let state = RepositoryState(lastUpdatedTimestamp: initialTimestamp)
        let action = Action.repositoryAction(.repositoryUpdated)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.lastUpdatedTimestamp > initialTimestamp)
    }

    func test_repositoryReducer_reduce_when_fetchInitialMessagesSuccessAction_then_stateUpdated() {
        let initialTimestamp = Date()
        let state = RepositoryState(hasFetchedInitialMessages: false)
        let action = Action.repositoryAction(.fetchInitialMessagesSuccess(messages: []))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.hasFetchedInitialMessages)
    }

    func test_repositoryReducer_reduce_when_fetchPreviousMessagesSuccessAction_notEmptyMessages_then_stateUpdated() {
        let initialTimestamp = Date()
        let state = RepositoryState(
            hasFetchedInitialMessages: false,
            hasExhaustedPreviousMessages: false)
        let action = Action.repositoryAction(.fetchPreviousMessagesSuccess(messages: [
            ChatMessageInfoModel()
        ]))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.hasFetchedPreviousMessages)
        XCTAssertFalse(resultState.hasExhaustedPreviousMessages)
    }

    func test_repositoryReducer_reduce_when_fetchPreviousMessagesSuccessAction_emptyMessages_then_stateUpdated() {
        let initialTimestamp = Date()
        let state = RepositoryState(
            hasFetchedInitialMessages: false,
            hasExhaustedPreviousMessages: false)
        let action = Action.repositoryAction(.fetchPreviousMessagesSuccess(messages: []))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.hasFetchedPreviousMessages)
        XCTAssertTrue(resultState.hasExhaustedPreviousMessages)
    }
}

extension RepositoryReducerTests {
    func getSUT() -> Reducer<RepositoryState, Action> {
        return .liveRepositoryReducer
    }
}

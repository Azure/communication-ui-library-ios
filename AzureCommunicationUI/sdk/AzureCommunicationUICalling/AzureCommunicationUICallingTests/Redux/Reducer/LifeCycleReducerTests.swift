//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class LifeCycleReducerTests: XCTestCase {
    // No longer possible with compile time type-checking
//    func test_lifeCycleReducer_reduce_when_notLocalUserState_then_return() {
//        let state = StateMocking()
//        let action = .microphoneOffTriggered()
//        let sut = getSUT()
//        let resultState = sut.reduce(state, action)
//
//        XCTAssert(resultState is StateMocking)
//    }

    func test_lifeCycleReducer_reduce_when_foregroundEnteredAction_then_stateUpdated() {
        let expectedState = AppStatus.foreground
        let state = LifeCycleState(currentStatus: .background)
        let action = LifecycleAction.foregroundEntered
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.currentStatus, expectedState)
    }

    func test_lifeCycleReducer_reduce_when_backgroundEnteredAction_then_stateUpdated() {
        let expectedState = AppStatus.background
        let state = LifeCycleState(currentStatus: .foreground)
        let action = LifecycleAction.backgroundEntered
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.currentStatus, expectedState)
    }

    func test_lifeCycleReducer_reduce_when_unhandledAction_then_stateNotUpdate() {
        let expectedState = AppStatus.background
        let state = LifeCycleState(currentStatus: expectedState)
        let action = LifecycleAction.compositeExitAction    // Currently not handled in reducer
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.currentStatus, expectedState)
    }
}

extension LifeCycleReducerTests {
    func getSUT() -> Reducer<LifeCycleState, LifecycleAction> {
        return .liveLifecycleReducer
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class LifeCycleReducerTests: XCTestCase {
    func test_lifeCycleReducer_reduce_when_notLocalUserState_then_return() {
        let state = StateMocking()
        let action = LocalUserAction.MicrophoneOffTriggered()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssert(resultState is StateMocking)
    }

    func test_lifeCycleReducer_reduce_when_foregroundEnteredAction_then_stateUpdated() {
        let expectedState = LifeCycleState.AppStatus.foreground
        let state = LifeCycleState(currentStatus: .background)
        let action = LifecycleAction.ForegroundEntered()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? LifeCycleState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState.currentStatus, expectedState)
    }

    func test_lifeCycleReducer_reduce_when_backgroundEnteredAction_then_stateUpdated() {
        let expectedState = LifeCycleState.AppStatus.background
        let state = LifeCycleState(currentStatus: .foreground)
        let action = LifecycleAction.BackgroundEntered()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? LifeCycleState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState.currentStatus, expectedState)
    }

    func test_lifeCycleReducer_reduce_when_mockingAction_then_stateNotUpdate() {
        let expectedState = LifeCycleState.AppStatus.background
        let state = LifeCycleState(currentStatus: expectedState)
        let action = ActionMocking()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? LifeCycleState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState.currentStatus, expectedState)
    }
}

extension LifeCycleReducerTests {
    func getSUT() -> LifeCycleReducer {
        return LifeCycleReducer()
    }

}

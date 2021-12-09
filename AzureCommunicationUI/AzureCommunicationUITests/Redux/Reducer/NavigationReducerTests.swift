//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class NavigationReducerTests: XCTestCase {
    func test_navigationReducer_reduce_when_notNavigationStatus_then_return() {
        let state = StateMocking()
        let action = CallingViewLaunched()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssert(resultState is StateMocking)
    }

    func test_navigationReducer_reduce_when_callingActionStateUpdatedNotDisconnected_then_stateNotUpdated() {
        let expectedState = NavigationState(status: .setup)
        let state = NavigationState(status: .setup)
        let action = CallingAction.StateUpdated(status: .connected)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? NavigationState else {
            XCTFail()
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_compositexitaction_then_stateExitUpdated() {
        let expectedState = NavigationState(status: .exit)
        let state = NavigationState(status: .setup)
        let action = CompositeExitAction()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? NavigationState else {
            XCTFail()
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_callingViewLaunched_then_stateinCallUpdated() {
        let expectedState = NavigationState(status: .inCall)
        let state = NavigationState(status: .exit)
        let action = CallingViewLaunched()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? NavigationState else {
            XCTFail()
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_mockingAction_then_stateNotUpdate() {
        let expectedState = NavigationState(status: .inCall)
        let action = ActionMocking()
        let sut = getSUT()
        let resultState = sut.reduce(expectedState, action)
        guard let resultState = resultState as? NavigationState else {
            XCTFail()
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }
}

extension NavigationReducerTests {
    private func getSUT() -> NavigationReducer {
        return NavigationReducer()
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class NavigationReducerTests: XCTestCase {

    func test_navigationReducer_reduce_when_callingActionStateUpdatedNotDisconnected_then_stateNotUpdated() {
        let expectedState = NavigationState(status: .setup)
        let state = NavigationState(status: .setup)
        let action = Action.callingAction(.stateUpdated(status: .connected))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_compositexitaction_then_stateExitUpdated() {
        let expectedState = NavigationState(status: .exit)
        let state = NavigationState(status: .setup)
        let action = Action.compositeExitAction
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_callingViewLaunched_then_stateinCallUpdated() {
        let expectedState = NavigationState(status: .inCall)
        let state = NavigationState(status: .exit)
        let action = Action.callingViewLaunched
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_action_not_applicable_then_stateNotUpdate() {
        let expectedState = NavigationState(status: .inCall)
        let action = Action.audioSessionAction(.audioInterruptEnded)
        let sut = getSUT()
        let resultState = sut.reduce(expectedState, action)
        XCTAssertEqual(resultState, expectedState)
    }
}

extension NavigationReducerTests {
    private func getSUT() -> Reducer<NavigationState, Action> {
        return .liveNavigationReducer
    }
}

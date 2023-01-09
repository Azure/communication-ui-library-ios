//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class NavigationReducerTests: XCTestCase {

    func test_navigationReducer_reduce_when_chatViewLaunchedAction_then_stateInChatUpdated() {
        let expectedState = NavigationState(status: .inChat)
        let action = Action.chatViewLaunched
        let sut = getSUT()
        let resultState = sut.reduce(expectedState, action)
        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_compositeExitAction_then_stateExitUpdated() {
        let expectedState = NavigationState(status: .exit)
        let action = Action.compositeExitAction
        let sut = getSUT()
        let resultState = sut.reduce(expectedState, action)
        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_action_not_applicable_then_stateNotUpdate() {
        let expectedState = NavigationState(status: .inChat)
        let action = Action.repositoryAction(.fetchInitialMessagesTriggered)
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

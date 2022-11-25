//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class LifeCycleReducerTests: XCTestCase {

    func test_lifeCycleReducer_reduce_when_foregroundEnteredAction_then_stateUpdated() {
        let expectedState = AppStatus.foreground
        let state = LifeCycleState(currentStatus: .background)
        let action = LifecycleAction.foregroundEntered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.currentStatus, expectedState)
    }

    func test_lifeCycleReducer_reduce_when_backgroundEnteredAction_then_stateUpdated() {
        let expectedState = AppStatus.background
        let state = LifeCycleState(currentStatus: .foreground)
        let action = LifecycleAction.backgroundEntered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.currentStatus, expectedState)
    }

    func test_lifeCycleReducer_reduce_when_willTerminateAction_then_stateUpdated() {
        let expectedState = AppStatus.willTerminate
        let state = LifeCycleState(currentStatus: .willTerminate)
        let action = LifecycleAction.willTerminate
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.currentStatus, expectedState)
    }

}

extension LifeCycleReducerTests {
    func makeSUT() -> Reducer<LifeCycleState, LifecycleAction> {
        return .liveLifecycleReducer
    }
}

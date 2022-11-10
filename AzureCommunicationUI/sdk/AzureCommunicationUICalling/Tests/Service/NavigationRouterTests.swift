//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class NavigationRouterTests: XCTestCase {
    var logger: LoggerMocking!

    override func setUp() {
        super.setUp()
        logger = LoggerMocking()
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
    }

    func test_router_navigate_whenNavigateToNewView_shouldCallLog() {
        let sut = makeSUT()
        let state = AppState(navigationState: NavigationState(status: .inCall))

        sut.receive(state)

        XCTAssertTrue(logger.logWasCalled(), "Log was not called")
    }

    func test_router_navigate_when_navigationStatusInCall_then_navigateToCallView() {
        let sut = makeSUT()
        let naviState = NavigationState(status: .inCall)
        let state = AppState(navigationState: naviState)

        sut.receive(state)

        XCTAssertEqual(
            sut.currentView,
            .callingView,
            "\(sut.currentView) is not the expected navigated view for state: \(state.callingState.status)")
    }

    func test_router_navigate_when_navigationStatusSetupView_then_navigateToSetupView() {
        let sut = makeSUT()
        let naviState = NavigationState(status: .setup)
        let state = AppState(navigationState: naviState)

        sut.receive(state)

        XCTAssertEqual(
            sut.currentView,
            .setupView,
            "\(sut.currentView) is not the expected navigated view for state: \(state.callingState.status)")
    }

    func test_router_navigate_when_navigationStatusExit_then_navigateToNone() {
        let sut = makeSUT()
        let naviState = NavigationState(status: .exit)
        let state = AppState(navigationState: naviState)

        sut.receive(state)

        XCTAssertEqual(
            sut.currentView,
            .setupView,
            "\(sut.currentView) is not the expected navigated view for state: \(state.callingState.status)")
    }
}

extension NavigationRouterTests {
    func makeSUT() -> NavigationRouter {
        let storeFactory = StoreFactoryMocking()
        return NavigationRouter(store: storeFactory.store, logger: logger)
    }
}

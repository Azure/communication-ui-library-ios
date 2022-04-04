//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class NavigationRouterTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var logger: LoggerMocking!
    var swiftUIRouter: NavigationRouter!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        logger = LoggerMocking()
        swiftUIRouter = NavigationRouter(store: storeFactory.store, logger: logger)
    }

    func test_router_navigate_whenNavigateToNewView_shouldCallLog() {
        let state = AppState(navigationState: NavigationState(status: .inCall))

        swiftUIRouter.receive(state)

        XCTAssertTrue(logger.logWasCalled(), "Log was not called")
    }

    func test_router_navigate_when_navigationStatusInCall_then_navigateToCallView() {
        let naviState = NavigationState(status: .inCall)
        let state = AppState(navigationState: naviState)

        swiftUIRouter.receive(state)

        XCTAssertEqual(
            swiftUIRouter.currentView,
            .callingView,
            "\(swiftUIRouter.currentView) is not the expected navigated view for state: \(state.callingState.status)")
    }

    func test_router_navigate_when_navigationStatusSetupView_then_navigateToSetupView() {
        let naviState = NavigationState(status: .setup)
        let state = AppState(navigationState: naviState)

        swiftUIRouter.receive(state)

        XCTAssertEqual(
            swiftUIRouter.currentView,
            .setupView,
            "\(swiftUIRouter.currentView) is not the expected navigated view for state: \(state.callingState.status)")
    }

    func test_router_navigate_when_navigationStatusExit_then_navigateToNone() {
        let naviState = NavigationState(status: .exit)
        let state = AppState(navigationState: naviState)

        swiftUIRouter.receive(state)

        XCTAssertEqual(
            swiftUIRouter.currentView,
            .setupView,
            "\(swiftUIRouter.currentView) is not the expected navigated view for state: \(state.callingState.status)")
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class NavigationRouterTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var logger: LoggerMocking!
    var swiftUIRouter: NavigationRouter!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        logger = LoggerMocking()
        cancellable = CancelBag()
        swiftUIRouter = NavigationRouter(store: storeFactory.store,
                                         logger: logger,
                                         chatCompositeEventsHandler: ChatComposite.Events())
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        logger = nil
        cancellable = nil
        swiftUIRouter = nil
    }

    func test_router_navigate_whenNavigateToChat_shouldNotDismiss() {
        let expectation = expectation(description: "Switch to inChat")
        let state = AppState(navigationState: NavigationState(status: .inChat))
        expectation.isInverted = true
        func dismiss() {
            XCTFail("should not be called")
        }
        swiftUIRouter.setDismissComposite(dismiss)
        swiftUIRouter.receive(state)
        wait(for: [expectation], timeout: 1)
    }

    func test_router_navigate_whenNavigateToHeadless_shouldDismiss() {
        let expectation = expectation(description: "Switch to headless")
        let state = AppState(navigationState: NavigationState(status: .headless))
        func dismiss() {
            expectation.fulfill()
        }
        swiftUIRouter.setDismissComposite(dismiss)
        swiftUIRouter.receive(state)
        wait(for: [expectation], timeout: 1)
    }
}

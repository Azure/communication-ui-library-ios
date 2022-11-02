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

    func test_router_navigate_whenNavigateToChat_shouldCallForegroundEntered() {
        let expectation = expectation(description: "Foreground Entered")
        let state = AppState(navigationState: NavigationState(status: .inChat))
        swiftUIRouter.receive(state)
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .lifecycleAction(.foregroundEntered))
                expectation.fulfill()
            }.store(in: cancellable)
        wait(for: [expectation], timeout: 1)
    }

    func test_router_navigate_whenNavigateToHeadless_shouldCallBackgroundEntered() {
        let expectation = expectation(description: "Background Entered")
        let state = AppState(navigationState: NavigationState(status: .headless))
        swiftUIRouter.receive(state)
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .lifecycleAction(.backgroundEntered))
                expectation.fulfill()
            }.store(in: cancellable)
        wait(for: [expectation], timeout: 1)
    }
}

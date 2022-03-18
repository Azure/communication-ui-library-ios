//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class CompositeErrorManagerTests: XCTestCase {
    var mockStoreFactory = StoreFactoryMocking()
    var cancellable: CancelBag!
    var compositeManager: CompositeErrorManager!
    var mockCallComposite = CallCompositeMocking(withOptions: CallCompositeOptions())
    var mockEventsHandler: CallCompositeEventsHandler?

    var handlerCallExpectation = XCTestExpectation(description: "Delegate expectation")
    var expectedError: ErrorEvent?

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        compositeManager = CompositeErrorManager(store: mockStoreFactory.store,
                                                 callCompositeEventsHandler: getEventsHandler())
    }

    func test_errorManager_receiveState_when_noFatalError_navigationExit_then_nodidFailEventCalled_hostingVCDismissCalled() {
        handlerCallExpectation.isInverted = true
        let newState = getAppState(naviState: NavigationState(status: .exit))
        mockStoreFactory.setState(newState)

        wait(for: [handlerCallExpectation], timeout: 1)
    }

    func test_errorManager_receiveState_when_noFatalError_callNotExisted_then_nodidFailEventCalled_hostingVCDismissCalled() {
        handlerCallExpectation.isInverted = true
        let newState = getAppState(naviState: NavigationState(status: .inCall))
        mockStoreFactory.setState(newState)

        wait(for: [handlerCallExpectation], timeout: 1)
    }

    func test_errorManager_receiveState_when_fatalErrorCallJoin_then_receiveDidFail() {
        let fatalError = ErrorEvent(code: CallCompositeErrorCode.callJoin, error: nil)
        self.expectedError = fatalError
        let errorState = ErrorState(error: fatalError, errorCategory: .callState)
        let newState = getAppState(errorState: errorState)

        mockStoreFactory.setState(newState)
        wait(for: [handlerCallExpectation], timeout: 1)
    }

    func test_errorManager_receiveState_when_fatalErrorTokenExpired_then_receiveEmergencyExitAction() {
        let fatalError = ErrorEvent(code: CallCompositeErrorCode.tokenExpired, error: nil)
        self.expectedError = fatalError
        let errorState = ErrorState.init(error: fatalError, errorCategory: .fatal)
        let newState = getAppState(errorState: errorState)
        let actionExpectation = XCTestExpectation(description: "Dispatch the new emergency exit action")

        mockStoreFactory.setState(newState)
        mockStoreFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                guard let self = self else {
                    XCTFail("self is nil")
                    return
                }
                XCTAssertTrue(self.mockStoreFactory.actions.first is CompositeExitAction)
                actionExpectation.fulfill()
            }.store(in: cancellable)

        wait(for: [handlerCallExpectation, actionExpectation], timeout: 1)
    }
}

extension CompositeErrorManagerTests {
    func getAppState(naviState: NavigationState = NavigationState(status: .setup)) -> AppState {
        return AppState(callingState: CallingState(),
                        permissionState: PermissionState(),
                        localUserState: LocalUserState(),
                        lifeCycleState: LifeCycleState(),
                        navigationState: naviState,
                        remoteParticipantsState: .init(),
                        errorState: .init())
    }

    func getAppState(errorState: ErrorState) -> AppState {
        return AppState(callingState: CallingState(),
                        permissionState: PermissionState(),
                        localUserState: LocalUserState(),
                        lifeCycleState: LifeCycleState(),
                        navigationState: NavigationState(status: .setup),
                        remoteParticipantsState: .init(),
                        errorState: errorState)
    }

    func getEventsHandler() -> CallCompositeEventsHandler {
        let handler = CallCompositeEventsHandler()
        handler.didFail = { [weak self] callCompositeError in
            guard let self = self else {
                return
            }

            XCTAssertEqual(callCompositeError.code, self.expectedError?.code)
            self.handlerCallExpectation.fulfill()

        }
        mockEventsHandler = handler
        return handler
    }
}

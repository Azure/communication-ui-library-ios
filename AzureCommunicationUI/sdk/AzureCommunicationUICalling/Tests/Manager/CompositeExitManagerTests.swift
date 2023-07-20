//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CompositeExitManagerTests: XCTestCase {
    var mockStoreFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var compositeExitManager: CompositeExitManager!
    var handlerCallExpectation: XCTestExpectation!
    var expectedError: Error?
    var expectedErrorCode: String = ""

    override func setUp() {
        super.setUp()
        handlerCallExpectation = XCTestExpectation(description: "Delegate expectation")
        mockStoreFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        compositeExitManager = CompositeExitManager(store: mockStoreFactory.store,
                                                 callCompositeEventsHandler: getEventsHandler())
    }

    override func tearDown() {
        super.tearDown()
        handlerCallExpectation = nil
        mockStoreFactory = nil
        cancellable = nil
        compositeExitManager = nil
    }

    func test_exitManager_when_connecting_callState_then_compositeExitActionCalled() {
        let callState = CallingState(status: CallingStatus.connecting,
                                     operationStatus: OperationStatus.callEnded,
                                     callId: "123",
                                     isRecordingActive: false,
                                     isTranscriptionActive: false,
                                     callStartDate: Date()
        )
        let newState = getAppState(errorState: ErrorState(), callingState: callState)
        let actionExpectation = XCTestExpectation(description: "Dispatch the callEndRequested action")

        mockStoreFactory.setState(newState)
        mockStoreFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                guard let self = self else {
                    XCTFail("self is nil")
                    return
                }
                XCTAssertTrue(self.mockStoreFactory.actions.first == Action.callingAction(.callEndRequested))
                actionExpectation.fulfill()
            }.store(in: cancellable)
        compositeExitManager.exit()

        wait(for: [actionExpectation], timeout: 1)
    }

    func test_exitManager_when_none_callState_then_callEndRequestedCalled() {
        let callState = CallingState(status: CallingStatus.none,
                                     operationStatus: OperationStatus.callEnded,
                                     callId: "123",
                                     isRecordingActive: false,
                                     isTranscriptionActive: false,
                                     callStartDate: Date()
        )
        let newState = getAppState(errorState: ErrorState(), callingState: callState)
        let actionExpectation = XCTestExpectation(description: "Dispatch the callEndRequested action")

        mockStoreFactory.setState(newState)
        mockStoreFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                guard let self = self else {
                    XCTFail("self is nil")
                    return
                }
                XCTAssertTrue(self.mockStoreFactory.actions.first == Action.compositeExitAction)
                actionExpectation.fulfill()
            }.store(in: cancellable)
        compositeExitManager.exit()

        wait(for: [actionExpectation], timeout: 1)
    }

    func test_exitManager_when_disconnected_callState_then_callEndRequestedCalled() {
        let callState = CallingState(status: CallingStatus.disconnected,
                                     operationStatus: OperationStatus.callEnded,
                                     callId: "123",
                                     isRecordingActive: false,
                                     isTranscriptionActive: false,
                                     callStartDate: Date()
        )
        let newState = getAppState(errorState: ErrorState(), callingState: callState)
        let actionExpectation = XCTestExpectation(description: "Dispatch the callEndRequested action")

        mockStoreFactory.setState(newState)
        mockStoreFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                guard let self = self else {
                    XCTFail("self is nil")
                    return
                }
                XCTAssertTrue(self.mockStoreFactory.actions.first == Action.compositeExitAction)
                actionExpectation.fulfill()
            }.store(in: cancellable)
        compositeExitManager.exit()

        wait(for: [actionExpectation], timeout: 1)
    }

    func test_exitManager_when_exit_then_sendEvent() {
        let callState = CallingState(status: CallingStatus.disconnected,
                                     operationStatus: OperationStatus.callEnded,
                                     callId: "123",
                                     isRecordingActive: false,
                                     isTranscriptionActive: false,
                                     callStartDate: Date()
        )
        let newState = getAppState(errorState: ErrorState(), callingState: callState)
        mockStoreFactory.setState(newState)
        compositeExitManager.onExited()

        wait(for: [handlerCallExpectation], timeout: 1)
    }

    func test_exitManager_when_exit_withNonFatalError_then_sendEventWithNoError() {
        let callState = CallingState(status: CallingStatus.disconnected,
                                     operationStatus: OperationStatus.callEnded,
                                     callId: "123",
                                     isRecordingActive: false,
                                     isTranscriptionActive: false,
                                     callStartDate: Date()
        )
        self.expectedError = nil
        self.expectedErrorCode = ""
        let errorState = ErrorState(internalError: .callTokenFailed,
                                    error: nil,
                                    errorCategory: .none)
        let newState = getAppState(errorState: errorState, callingState: callState)
        mockStoreFactory.setState(newState)
        compositeExitManager.onExited()

        wait(for: [handlerCallExpectation], timeout: 1)
    }

    func test_exitManager_when_exit_withFatalError_then_sendEventWithFatalError() {
        let callState = CallingState(status: CallingStatus.disconnected,
                                     operationStatus: OperationStatus.callEnded,
                                     callId: "123",
                                     isRecordingActive: false,
                                     isTranscriptionActive: false,
                                     callStartDate: Date()
        )
        self.expectedError = nil
        self.expectedErrorCode = CallCompositeErrorCode.tokenExpired
        let errorState = ErrorState(internalError: .callTokenFailed,
                                    error: nil,
                                    errorCategory: .fatal)
        let newState = getAppState(errorState: errorState, callingState: callState)
        mockStoreFactory.setState(newState)
        compositeExitManager.onExited()

        wait(for: [handlerCallExpectation], timeout: 1)
    }
}

extension CompositeExitManagerTests {
    func getAppState(naviState: NavigationState = NavigationState(status: .setup)) -> AppState {
        return AppState(callingState: CallingState(),
                        permissionState: PermissionState(),
                        localUserState: LocalUserState(),
                        lifeCycleState: LifeCycleState(),
                        navigationState: naviState,
                        remoteParticipantsState: .init(),
                        errorState: .init())
    }

    func getAppState(errorState: ErrorState, callingState: CallingState) -> AppState {
        return AppState(callingState: callingState,
                        permissionState: PermissionState(),
                        localUserState: LocalUserState(),
                        lifeCycleState: LifeCycleState(),
                        navigationState: NavigationState(status: .setup),
                        remoteParticipantsState: .init(),
                        errorState: errorState)
    }

    func getEventsHandler() -> CallComposite.Events {
        let handler = CallComposite.Events()
        handler.onExited = { [weak self] callCompositeExit in
            guard let self = self else {
                return
            }
            XCTAssertEqual(callCompositeExit.error?.localizedDescription, self.expectedError?.localizedDescription)
            XCTAssertEqual(callCompositeExit.code, self.expectedErrorCode)

            self.handlerCallExpectation.fulfill()
        }
        return handler
    }
}

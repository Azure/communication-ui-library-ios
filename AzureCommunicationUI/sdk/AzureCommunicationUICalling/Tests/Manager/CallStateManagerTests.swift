//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CompositeStateManagerTests: XCTestCase {
    var mockStoreFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var callStateManager: CallStateManager!

    var handlerCallExpectation: XCTestExpectation!
    var expectedCallStateCode: CallState?
    var stateChangeCount: Int = 0
    var expectedStateChangeCount: Int = 0

    override func setUp() {
        super.setUp()
        stateChangeCount = 0
        expectedStateChangeCount = 0
        handlerCallExpectation = XCTestExpectation(description: "Delegate expectation")
        mockStoreFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        callStateManager = CallStateManager(store: mockStoreFactory.store,
                                                 callCompositeEventsHandler: getEventsHandler())
    }

    override func tearDown() {
        super.tearDown()
        handlerCallExpectation = nil
        mockStoreFactory = nil
        cancellable = nil
        callStateManager = nil
    }

    private func testCallingStatus(_ status: CallingStatus) {
        let callState = CallingState(status: status,
                                     operationStatus: OperationStatus.callEnded,
                                     callId: "123",
                                     isRecordingActive: false,
                                     isTranscriptionActive: false,
                                     callStartDate: Date()
        )
        let newState = getAppState(callingState: callState)
        expectedCallStateCode = status.toCallCompositeCallState()
        mockStoreFactory.setState(newState)
        wait(for: [handlerCallExpectation], timeout: 1)
    }

    func test_callStateManager_when_reduxStateChangedToNone_then_stateEventHandlerCalledWithNoneState() {
        let status = CallingStatus.none
        expectedStateChangeCount = 1
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToConnected_then_stateEventHandlerCalledWithConnectedState() {
        let status = CallingStatus.connected
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToConnecting_then_stateEventHandlerCalledWithConnectingState() {
        let status = CallingStatus.connecting
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToDisconnecting_then_stateEventHandlerCalledWithDisconnectingState() {
        let status = CallingStatus.disconnecting
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToDisconnected_then_stateEventHandlerCalledWithDisconnectedState() {
        let status = CallingStatus.disconnected
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToEarlyMedia_then_stateEventHandlerCalledWithEarlyMediaState() {
        let status = CallingStatus.earlyMedia
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToInLobby_then_stateEventHandlerCalledWithInLobbyState() {
        let status = CallingStatus.inLobby
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToLocalHold_then_stateEventHandlerCalledWithLocalHoldState() {
        let status = CallingStatus.localHold
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToRemoteHold_then_stateEventHandlerCalledWithRemoteHoldState() {
        let status = CallingStatus.remoteHold
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }

    func test_callStateManager_when_reduxStateChangedToRinging_then_stateEventHandlerCalledWithRingingState() {
        let status = CallingStatus.ringing
        expectedStateChangeCount = 2
        testCallingStatus(status)
    }
}

extension CompositeStateManagerTests {
    func getAppState(naviState: NavigationState = NavigationState(status: .setup)) -> AppState {
        return AppState(callingState: CallingState(),
                        permissionState: PermissionState(),
                        localUserState: LocalUserState(),
                        lifeCycleState: LifeCycleState(),
                        navigationState: naviState,
                        remoteParticipantsState: .init(),
                        errorState: .init())
    }

    func getAppState(callingState: CallingState) -> AppState {
        return AppState(callingState: callingState,
                        permissionState: PermissionState(),
                        localUserState: LocalUserState(),
                        lifeCycleState: LifeCycleState(),
                        navigationState: NavigationState(status: .setup),
                        remoteParticipantsState: .init(),
                        errorState: ErrorState())
    }

    func getEventsHandler() -> CallComposite.Events {
        let handler = CallComposite.Events()
        handler.onCallStateChanged = { [weak self] callState in
            guard let self = self else {
                return
            }
            self.stateChangeCount += 1
            if self.stateChangeCount == self.expectedStateChangeCount {
                XCTAssertEqual(callState, self.expectedCallStateCode)
                self.handlerCallExpectation.fulfill()
            } else {
                XCTAssertEqual(callState, CallState.none)
            }
        }
        return handler
    }
}

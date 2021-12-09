//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class CallingViewModelTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!

    var callingViewModel: CallingViewModel!

    private let timeout: TimeInterval = 10.0

    override func setUp() {
        cancellable = CancelBag()

        storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        callingViewModel = CallingViewModel(compositeViewModelFactory: factoryMocking,
                                            logger: LoggerMocking(),
                                            store: storeFactory.store)
    }

    func test_callingViewModel_getLeaveCallButtonViewModel_shouldReturnPrimaryButtonViewModel() {
        let leaveCallButtonViewModel = callingViewModel.getLeaveCallButtonViewModel()
        let expectedButtonLabel = "Leave call"

        XCTAssertEqual(leaveCallButtonViewModel.buttonLabel, expectedButtonLabel)
    }

    func test_callingViewModel_getCancelButtonViewModel_shouldReturnPrimaryButtonViewModel() {
        let cancelButtonViewModel = callingViewModel.getCancelButtonViewModel()
        let expectedButtonLabel = "Cancel"

        XCTAssertEqual(cancelButtonViewModel.buttonLabel, expectedButtonLabel)
    }

    func test_callingViewModel_displayConfirmLeaveOverlay_when_isConfirmLeaveOverlayDisplayedFalse_shouldBecomeTrue() {
        callingViewModel.isConfirmLeaveOverlayDisplayed = false
        callingViewModel.displayConfirmLeaveOverlay()

        XCTAssertTrue(callingViewModel.isConfirmLeaveOverlayDisplayed)
    }

    func test_callingViewModel_dismissConfirmLeaveOverlay_when_isConfirmLeaveOverlayDisplayedTrue_shouldBecomeFalse() {
        callingViewModel.isConfirmLeaveOverlayDisplayed = true
        callingViewModel.dismissConfirmLeaveOverlay()

        XCTAssertFalse(callingViewModel.isConfirmLeaveOverlayDisplayed)
    }

    func test_callingViewModel_startCall_when_currentCallingStateIsNone_shouldStartCall() {
        let expectation = XCTestExpectation(description: "Verify Call Start is Requested")

        callingViewModel.startCall()

        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first is CallingAction.CallStartRequested)

                expectation.fulfill()
            }.store(in: cancellable)

        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_endCall_when_confirmLeaveOverlayIsDisplayed_shouldEndCall() {
        let expectation = XCTestExpectation(description: "Verify Call End is Requested")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first is CallingAction.CallEndRequested)

                expectation.fulfill()
            }.store(in: cancellable)

        callingViewModel.isConfirmLeaveOverlayDisplayed = true
        callingViewModel.endCall()
        XCTAssertFalse(callingViewModel.isConfirmLeaveOverlayDisplayed)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_update_when_callStatusIsInLobby_then_isLobbyOverlayDisplayed_shouldBecomeTrue() {
        let appState = AppState(callingState: CallingState(status: .inLobby))
        callingViewModel.receive(appState)
        XCTAssert(callingViewModel.isLobbyOverlayDisplayed)
    }

    func test_callingViewModel_update_when_callStatusIsConnected_then_isLobbyOverlayDisplayed_shouldBecomeFalse() {
        let appState = AppState(callingState: CallingState(status: .connected))
        callingViewModel.receive(appState)
        XCTAssertFalse(callingViewModel.isLobbyOverlayDisplayed)
    }

    func test_callingViewModel_update_when_lifeCycleStateIsBackground_callStatusIsInLobby_then_isLobbyOverlayDisplayed_shouldKeepSame() {
        let originalState = callingViewModel.isLobbyOverlayDisplayed
        let appState = AppState(callingState: CallingState(status: .inLobby),
                                lifeCycleState: LifeCycleState(currentStatus: .background))
        callingViewModel.receive(appState)
        XCTAssertEqual(callingViewModel.isLobbyOverlayDisplayed, originalState)
    }

    func test_callingViewModel_update_when_callStatusIsConnected_remoteParticipantNotEmpty_then_isParticipantGridDisplayed_shouldBecomeTrue() {
        let mockingParticipantInfoModel = ParticipantInfoModelBuilder.get()
        let remoteParticipantState = RemoteParticipantsState(participantInfoList: [mockingParticipantInfoModel],
                                                             lastUpdateTimeStamp: Date())
        let appState = AppState(callingState: CallingState(status: .connected),
                                remoteParticipantsState: remoteParticipantState)
        callingViewModel.receive(appState)
        XCTAssertEqual(callingViewModel.isParticipantGridDisplayed, true)
    }

    func test_callingViewModel_update_when_callStatusIsNotConnected_remoteParticipantNotEmpty_then_isParticipantGridDisplayed_shouldBecomeFalse() {
        let mockingParticipantInfoModel = ParticipantInfoModelBuilder.get()
        let remoteParticipantState = RemoteParticipantsState(participantInfoList: [mockingParticipantInfoModel],
                                                             lastUpdateTimeStamp: Date())
        let appState = AppState(callingState: CallingState(status: .inLobby),
                                remoteParticipantsState: remoteParticipantState)
        callingViewModel.receive(appState)
        XCTAssertEqual(callingViewModel.isParticipantGridDisplayed, false)
    }

    func test_callingViewModel_update_when_callStatusIsNotConnected_remoteParticipantEmpty_then_isParticipantGridDisplayed_shouldBecomeFalse() {
        let remoteParticipantState = RemoteParticipantsState(participantInfoList: [],
                                                             lastUpdateTimeStamp: Date())
        let appState = AppState(callingState: CallingState(status: .connected),
                                remoteParticipantsState: remoteParticipantState)
        callingViewModel.receive(appState)
        XCTAssertEqual(callingViewModel.isParticipantGridDisplayed, false)
    }
}

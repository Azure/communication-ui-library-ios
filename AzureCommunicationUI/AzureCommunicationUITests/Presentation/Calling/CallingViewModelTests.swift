//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class CallingViewModelTests: XCTestCase {
    var cancellable = CancelBag()
    var logger = LoggerMocking()

    private let timeout: TimeInterval = 10.0

    func test_callingViewModel_getLeaveCallButtonViewModel_shouldReturnPrimaryButtonViewModel() {
        let sut = makeSUT()
        let leaveCallButtonViewModel = sut.getLeaveCallButtonViewModel()
        let expectedButtonLabel = "Leave call"

        XCTAssertEqual(leaveCallButtonViewModel.buttonLabel, expectedButtonLabel)
    }

    func test_callingViewModel_getCancelButtonViewModel_shouldReturnPrimaryButtonViewModel() {
        let sut = makeSUT()
        let cancelButtonViewModel = sut.getCancelButtonViewModel()
        let expectedButtonLabel = "Cancel"

        XCTAssertEqual(cancelButtonViewModel.buttonLabel, expectedButtonLabel)
    }

    func test_callingViewModel_displayConfirmLeaveOverlay_when_isConfirmLeaveOverlayDisplayedFalse_shouldBecomeTrue() {
        let sut = makeSUT()
        sut.isConfirmLeaveOverlayDisplayed = false
        sut.displayConfirmLeaveOverlay()

        XCTAssertTrue(sut.isConfirmLeaveOverlayDisplayed)
    }

    func test_callingViewModel_dismissConfirmLeaveOverlay_when_isConfirmLeaveOverlayDisplayedTrue_shouldBecomeFalse() {
        let sut = makeSUT()
        sut.isConfirmLeaveOverlayDisplayed = true
        sut.dismissConfirmLeaveOverlay()

        XCTAssertFalse(sut.isConfirmLeaveOverlayDisplayed)
    }

    func test_callingViewModel_endCall_when_confirmLeaveOverlayIsDisplayed_shouldEndCall() {
        let storeFactory = StoreFactoryMocking()
        let sut = makeSUT(storeFactory: storeFactory)
        let expectation = XCTestExpectation(description: "Verify Call End is Requested")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak storeFactory] _ in
                XCTAssertEqual(storeFactory?.actions.count, 1)
                XCTAssertTrue(storeFactory?.actions.first is CallingAction.CallEndRequested)

                expectation.fulfill()
            }.store(in: cancellable)
        sut.isConfirmLeaveOverlayDisplayed = true
        sut.endCall()
        XCTAssertFalse(sut.isConfirmLeaveOverlayDisplayed)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_update_when_callStatusIsInLobby_then_isLobbyOverlayDisplayed_shouldBecomeTrue() {
        let sut = makeSUT()
        let appState = AppState(callingState: CallingState(status: .inLobby))
        sut.receive(appState)
        XCTAssert(sut.isLobbyOverlayDisplayed)
    }

    func test_callingViewModel_update_when_callStatusIsConnected_then_isLobbyOverlayDisplayed_shouldBecomeFalse() {
        let sut = makeSUT()
        let appState = AppState(callingState: CallingState(status: .connected))
        sut.receive(appState)
        XCTAssertFalse(sut.isLobbyOverlayDisplayed)
    }

    func test_callingViewModel_update_when_lifeCycleStateIsBackground_callStatusIsInLobby_then_isLobbyOverlayDisplayed_shouldKeepSame() {
        let sut = makeSUT()
        let originalState = sut.isLobbyOverlayDisplayed
        let appState = AppState(callingState: CallingState(status: .inLobby),
                                lifeCycleState: LifeCycleState(currentStatus: .background))
        sut.receive(appState)
        XCTAssertEqual(sut.isLobbyOverlayDisplayed, originalState)
    }

    func test_callingViewModel_update_when_callStatusIsConnected_remoteParticipantNotEmpty_then_isParticipantGridDisplayed_shouldBecomeTrue() {
        let sut = makeSUT()
        let mockingParticipantInfoModel = ParticipantInfoModelBuilder.get()
        let remoteParticipantState = RemoteParticipantsState(participantInfoList: [mockingParticipantInfoModel],
                                                             lastUpdateTimeStamp: Date())
        let appState = AppState(callingState: CallingState(status: .connected),
                                remoteParticipantsState: remoteParticipantState)
        sut.receive(appState)
        XCTAssertEqual(sut.isParticipantGridDisplayed, true)
    }

    func test_callingViewModel_update_when_callStatusIsNotConnected_remoteParticipantNotEmpty_then_isParticipantGridDisplayed_shouldBecomeFalse() {
        let sut = makeSUT()
        let mockingParticipantInfoModel = ParticipantInfoModelBuilder.get()
        let remoteParticipantState = RemoteParticipantsState(participantInfoList: [mockingParticipantInfoModel],
                                                             lastUpdateTimeStamp: Date())
        let appState = AppState(callingState: CallingState(status: .inLobby),
                                remoteParticipantsState: remoteParticipantState)
        sut.receive(appState)
        XCTAssertEqual(sut.isParticipantGridDisplayed, false)
    }

    func test_callingViewModel_update_when_callStatusIsNotConnected_remoteParticipantEmpty_then_isParticipantGridDisplayed_shouldBecomeFalse() {
        let sut = makeSUT()
        let remoteParticipantState = RemoteParticipantsState(participantInfoList: [],
                                                             lastUpdateTimeStamp: Date())
        let appState = AppState(callingState: CallingState(status: .connected),
                                remoteParticipantsState: remoteParticipantState)
        sut.receive(appState)
        XCTAssertEqual(sut.isParticipantGridDisplayed, false)
    }

    func test_callingViewModel_receive_when_statusUpdated_then_controlBarViewModelUpdated() {
        let expectation = XCTestExpectation(description: "ControlBarViewModel is updated")
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted),
                                localUserState: LocalUserState(displayName: "DisplayName"))
        let sut = makeSUT(updateControlBarViewModel: { userState, permissionState in
            XCTAssertEqual(appState.localUserState.displayName, userState.displayName)
            XCTAssertEqual(appState.permissionState.audioPermission, permissionState.audioPermission)
            expectation.fulfill()
        })
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_receive_when_statusUpdated_then_infoHeaderViewModelUpdated() {
        let expectation = XCTestExpectation(description: "InfoHeaderViewModel is updated")
        let appState = AppState(localUserState: LocalUserState(displayName: "DisplayName"))
        let sut = makeSUT(updateInfoHeaderViewModel: { userState, remoteParticipantsState in
            XCTAssertEqual(appState.localUserState.displayName, userState.displayName)
            XCTAssertEqual(appState.remoteParticipantsState.lastUpdateTimeStamp, remoteParticipantsState.lastUpdateTimeStamp)
            expectation.fulfill()
        })
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_receive_when_statusUpdated_then_localVideoViewModelUpdated() {
        let expectation = XCTestExpectation(description: "LocalVideoViewModel is updated")
        let appState = AppState(localUserState: LocalUserState(displayName: "DisplayName"))
        let sut = makeSUT(updateLocalVideoViewModel: { userState in
            XCTAssertEqual(appState.localUserState.displayName, userState.displayName)
            expectation.fulfill()
        })
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_receive_when_statusUpdated_then_participantGridViewModelUpdated() {
        let expectation = XCTestExpectation(description: "ParticipantGridViewModel is updated")
        let appState = AppState()
        let sut = makeSUT(updateParticipantGridViewModel: { remoteParticipantsState, _ in
            XCTAssertEqual(appState.remoteParticipantsState.lastUpdateTimeStamp, remoteParticipantsState.lastUpdateTimeStamp)
            expectation.fulfill()
        })
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_receive_when_statusUpdated_then_bannerViewModelUpdated() {
        let expectation = XCTestExpectation(description: "BannerViewModel is updated")
        let appState = AppState(callingState: CallingState(status: .connected))
        let sut = makeSUT(updateBannerViewModel: { callingState in
            XCTAssertEqual(appState.callingState.status, callingState.status)
            expectation.fulfill()
        })
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }
}

extension CallingViewModelTests {
    func makeSUT(storeFactory: StoreFactoryMocking = StoreFactoryMocking()) -> CallingViewModel {
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store)
    }

    func makeSUT(updateControlBarViewModel: @escaping ((LocalUserState, PermissionState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.controlBarViewModel = ControlBarViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                        logger: logger,
                                                                        dispatchAction: storeFactory.store.dispatch,
                                                                        endCallConfirm: {},
                                                                        localUserState: storeFactory.store.state.localUserState,
                                                                        updateState: updateControlBarViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store)
    }

    func makeSUT(updateInfoHeaderViewModel: @escaping ((LocalUserState, RemoteParticipantsState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.infoHeaderViewModel = InfoHeaderViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                        logger: logger,
                                                                        localUserState: storeFactory.store.state.localUserState,
                                                                        updateState: updateInfoHeaderViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store)
    }

    func makeSUT(updateLocalVideoViewModel: @escaping ((LocalUserState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.localVideoViewModel = LocalVideoViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                        logger: logger,
                                                                        dispatchAction: storeFactory.store.dispatch,
                                                                        updateState: updateLocalVideoViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store)
    }

    func makeSUT(updateParticipantGridViewModel: @escaping ((RemoteParticipantsState, LifeCycleState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.participantGridViewModel = ParticipantGridViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                                  updateState: updateParticipantGridViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store)
    }

    func makeSUT(updateBannerViewModel: @escaping ((CallingState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.bannerViewModel = BannerViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                updateState: updateBannerViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store)
    }

    func test_callingViewModel_update_when_callStatusIsConnected_appStateForeground_then_switchToBackground_shouldBecomeBackground() {
        let sut = makeSUT()
        let appState = AppState(callingState: CallingState(status: .connected),
                                lifeCycleState: LifeCycleState(currentStatus: .background))
        sut.receive(appState)
        XCTAssertEqual(sut.appState, .background)
    }

    func test_callingViewModel_update_when_callStatusIsConnected_appStateBackground_then_switchToForeground_shouldBecomeForeground() {
        let sut = makeSUT()
        let appState = AppState(callingState: CallingState(status: .connected),
                                lifeCycleState: LifeCycleState(currentStatus: .foreground))
        sut.receive(appState)
        XCTAssertEqual(sut.appState, .foreground)
    }

}

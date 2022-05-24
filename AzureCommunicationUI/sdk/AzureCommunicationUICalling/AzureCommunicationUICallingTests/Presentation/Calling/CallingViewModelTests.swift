//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallingViewModelTests: XCTestCase {
    var cancellable = CancelBag()
    var logger = LoggerMocking()
    var localizationProvider: LocalizationProviderMocking!

    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
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
        sut.isConfirmLeaveListDisplayed = true
        sut.endCall()
        XCTAssertFalse(sut.isConfirmLeaveListDisplayed)
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
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let appState = AppState(callingState: CallingState(status: .connected),
                                localUserState: LocalUserState(displayName: "DisplayName"),
                                remoteParticipantsState: RemoteParticipantsState(lastUpdateTimeStamp: date))
        let sut = makeSUT(state: appState, updateInfoHeaderViewModel: { userState, remoteParticipantsState, callingState in
            XCTAssertEqual(appState.localUserState.displayName, userState.displayName)
            XCTAssertEqual(appState.remoteParticipantsState.lastUpdateTimeStamp, remoteParticipantsState.lastUpdateTimeStamp)
            XCTAssertEqual(appState.callingState.status, callingState.status)
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
        let sut = makeSUT(updateParticipantGridViewModel: { _, remoteParticipantsState in
            XCTAssertEqual(appState.remoteParticipantsState.lastUpdateTimeStamp, remoteParticipantsState.lastUpdateTimeStamp)
            expectation.fulfill()
        })
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_receive_when_statusUpdated_then_bannerViewModelUpdated() {
        let expectation = XCTestExpectation(description: "BannerViewModel is updated")
        let appState = AppState(callingState: CallingState(status: .connected))
        let sut = makeSUT(state: appState, updateBannerViewModel: { callingState in
            XCTAssertEqual(appState.callingState.status, callingState.status)
            expectation.fulfill()
        })
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_callingViewModel_receive_when_callingStateStatusUpdated_then_accessibilityFocusUpdated() {
        let expectation = XCTestExpectation(description: "Accessibility focus is updated")
        let appState = AppState(callingState: CallingState(status: .inLobby))
        let accessibilityProvider = AccessibilityProviderMocking()
        accessibilityProvider.moveFocusToFirstElementBlock = {
            expectation.fulfill()
        }
        let sut = makeSUT(accessibilityProvider: accessibilityProvider)
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }
}

extension CallingViewModelTests {
    func makeSUT(storeFactory: StoreFactoryMocking = StoreFactoryMocking(),
                 accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider()) -> CallingViewModel {
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store,
                                localizationProvider: LocalizationProvider(logger: logger),
                                accessibilityProvider: accessibilityProvider,
                                isIPadInterface: false)
    }

    func makeSUTLocalizationMocking(storeFactory: StoreFactoryMocking = StoreFactoryMocking()) -> CallingViewModel {
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store,
                                localizationProvider: localizationProvider,
                                accessibilityProvider: AccessibilityProvider(),
                                isIPadInterface: false)
    }

    func makeSUT(updateControlBarViewModel: @escaping ((LocalUserState, PermissionState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.controlBarViewModel = ControlBarViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                        logger: logger,
                                                                        localizationProvider: localizationProvider,
                                                                        dispatchAction: storeFactory.store.dispatch,
                                                                        endCallConfirm: {},
                                                                        localUserState: storeFactory.store.state.localUserState,
                                                                        updateState: updateControlBarViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store,
                                localizationProvider: LocalizationProviderMocking(),
                                accessibilityProvider: AccessibilityProvider(),
                                isIPadInterface: false)
    }

    func makeSUT(state: AppState? = nil, updateInfoHeaderViewModel: @escaping ((LocalUserState, RemoteParticipantsState, CallingState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        if let state = state {
            storeFactory.store.state = state
        }
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.infoHeaderViewModel = InfoHeaderViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                        logger: logger,
                                                                        localUserState: storeFactory.store.state.localUserState,
                                                                        accessibilityProvider: AccessibilityProviderMocking(),
                                                                        updateState: updateInfoHeaderViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store,
                                localizationProvider: LocalizationProviderMocking(),
                                accessibilityProvider: AccessibilityProvider(),
                                isIPadInterface: false)
    }

    func makeSUT(state: AppState? = nil, updateLocalVideoViewModel: @escaping ((LocalUserState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        if let state = state {
            storeFactory.store.state = state
        }
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.localVideoViewModel = LocalVideoViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                        logger: logger,
                                                                        localizationProvider: localizationProvider,
                                                                        dispatchAction: storeFactory.store.dispatch,
                                                                        updateState: updateLocalVideoViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store,
                                localizationProvider: LocalizationProviderMocking(),
                                accessibilityProvider: AccessibilityProvider(),
                                isIPadInterface: false)
    }

    func makeSUT(state: AppState? = nil, updateParticipantGridViewModel: @escaping ((CallingState, RemoteParticipantsState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        if let state = state {
            storeFactory.store.state = state
        }
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.participantGridViewModel = ParticipantGridViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                                  localizationProvider: localizationProvider,
                                                                                  accessibilityProvider: AccessibilityProviderMocking(),
                                                                                  updateState: updateParticipantGridViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store,
                                localizationProvider: LocalizationProviderMocking(),
                                accessibilityProvider: AccessibilityProvider(),
                                isIPadInterface: false)
    }

    func makeSUT(state: AppState? = nil, updateBannerViewModel: @escaping ((CallingState) -> Void)) -> CallingViewModel {
        let storeFactory = StoreFactoryMocking()
        if let state = state {
            storeFactory.store.state = state
        }
        let factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        factoryMocking.bannerViewModel = BannerViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                updateState: updateBannerViewModel)
        return CallingViewModel(compositeViewModelFactory: factoryMocking,
                                logger: logger,
                                store: storeFactory.store,
                                localizationProvider: LocalizationProviderMocking(),
                                accessibilityProvider: AccessibilityProvider(),
                                isIPadInterface: false)
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

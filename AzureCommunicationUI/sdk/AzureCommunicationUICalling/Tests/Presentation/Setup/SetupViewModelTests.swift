//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class SetupViewModelTests: XCTestCase {
    private var storeFactory: StoreFactoryMocking!
    private var factoryMocking: CompositeViewModelFactoryMocking!
    private var cancellable: CancelBag!
    private var logger: LoggerMocking!
    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger,
                                                          store: storeFactory.store)
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        cancellable = nil
        logger = nil
        factoryMocking = nil
    }

    func test_setupViewModel_when_setupViewLoaded_then_shouldAskAudioPermission() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Verify Last Action is Request Audio")
        storeFactory.store.$state
            .dropFirst(2)
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last == Action.permissionAction(.audioPermissionRequested))

                expectation.fulfill()
            }.store(in: cancellable)
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .notAsked))
        sut.receive(storeFactory.store.state)
        sut.setupAudioPermissions()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_when_setupViewLoaded_then_shouldSetupCall() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Verify Last Action is SetupCall")

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last == Action.callingAction(.setupCall))

                expectation.fulfill()
            }.store(in: cancellable)
        sut.setupCall()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_when_joinCallButtonTapped_then_shouldCallStartRequest_isJoinRequestedTrue() {
        let expectation = XCTestExpectation(description: "Verify Last Action is Calling View Launched")
        let sut = makeSUT()

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last == Action.callingAction(.callStartRequested))
                expectation.fulfill()
            }.store(in: cancellable)
        sut.joinCallButtonTapped()
        XCTAssertTrue(sut.isJoinRequested)
        wait(for: [expectation], timeout: timeout)
    }

    func test_joinCallButtonViewModel_when_audioPermissionDenied_then_shouldDisablejoinCallButton() {
        let sut = makeSUT()
        let permissionState = PermissionState(audioPermission: .denied,
                                              cameraPermission: .notAsked)
        sut.joinCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)

        XCTAssertTrue(sut.joinCallButtonViewModel.isDisabled)
    }

    func test_joinCallButtonViewModel_when_audioPermissionGranted_then_shouldEnablejoinCallButton() {
        let sut = makeSUT()
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .denied)
        sut.joinCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)

        XCTAssertFalse(sut.joinCallButtonViewModel.isDisabled)

    }

    func test_setupViewModel_when_callingStateUpdateToNone_then_isJoinRequestedFalse() {
        let sut = makeSUT()
        sut.joinCallButtonTapped()

        let callingState = getCallingState(CallingStatus.connecting)
        let appState = AppState(callingState: callingState)
        sut.receive(appState)

        let updatedCallingState = getCallingState(CallingStatus.none)
        let updatedAppState = AppState(callingState: updatedCallingState)
        sut.receive(updatedAppState)

        XCTAssertFalse(sut.isJoinRequested)
    }

    func test_setupViewModel_when_callingStateUpdateToConnecting_then_isJoinRequestedTrue() {
        let sut = makeSUT()
        sut.joinCallButtonTapped()

        let updatedCallingState = getCallingState(CallingStatus.connecting)
        let updatedAppState = AppState(callingState: updatedCallingState)
        sut.receive(updatedAppState)

        XCTAssertTrue(sut.isJoinRequested)
    }

    func test_setupViewModel_receive_when_appStateUpdated_then_reviewAreaViewModelUpdated() {
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted),
                                localUserState: LocalUserState(displayName: "DisplayName"))
        let expectation = XCTestExpectation(description: "PreviewAreaViewModel is updated")
        let updatePreviewAreaViewModel: ((LocalUserState, PermissionState) -> Void) = { userState, permissionsState in
            XCTAssertEqual(userState.displayName, appState.localUserState.displayName)
            XCTAssertEqual(permissionsState.audioPermission, appState.permissionState.audioPermission)
            expectation.fulfill()
        }
        factoryMocking.previewAreaViewModel = PreviewAreaViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                          dispatchAction: storeFactory.store.dispatch,
                                                                          updateState: updatePreviewAreaViewModel)
        let sut = makeSUT()
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_receive_when_appStateUpdated_then_setupControlBarViewModelUpdated() {
        let appState = AppState(callingState: CallingState(status: .connected),
                                permissionState: PermissionState(audioPermission: .granted),
                                localUserState: LocalUserState(displayName: "DisplayName"))
        let expectation = XCTestExpectation(description: "SetupControlBarViewModel is updated")
        let updateSetupControlBarViewModel: ((LocalUserState, PermissionState, CallingState) -> Void) = { userState, permissionsState, callingState in
            XCTAssertEqual(userState.displayName, appState.localUserState.displayName)
            XCTAssertEqual(permissionsState.audioPermission, appState.permissionState.audioPermission)
            XCTAssertEqual(callingState, appState.callingState)
            expectation.fulfill()
        }
        factoryMocking.setupControlBarViewModel = SetupControlBarViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                                  logger: logger,
                                                                                  dispatchAction: storeFactory.store.dispatch,
                                                                                  localUserState: LocalUserState(),
                                                                                  updateState: updateSetupControlBarViewModel)
        let sut = makeSUT()
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_receive_when_isJoinRequestedTrue_then_setupControlBarViewModelUpdatedTrue() {
        let expectation = XCTestExpectation(description: "SetupControlBarViewModel is updated")

        let setupControlBarViewModel = SetupControlBarViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                       logger: logger,
                                                                       dispatchAction: storeFactory.store.dispatch,
                                                                       localUserState: LocalUserState())
        factoryMocking.setupControlBarViewModel = setupControlBarViewModel
        let sut = makeSUT()
        let updateIsJoinRequested: ((Bool) -> Void) = { isJoinRequested in
            XCTAssertTrue(isJoinRequested)
            expectation.fulfill()
        }
        setupControlBarViewModel.updateIsJoinRequested = updateIsJoinRequested
        sut.isJoinRequested = true
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_receive_when_appStateUpdated_then_joinCallButtonViewModelUpdated() {
        let appState = AppState()
        let expectation = XCTestExpectation(description: "JoinCallButtonViewModel is updated")
        let updateJoinCallButtonViewModel: ((Bool) -> Void) = { isDisabled in
            XCTAssertEqual(isDisabled, appState.permissionState.audioPermission == .denied)
            expectation.fulfill()
        }
        factoryMocking.primaryButtonViewModel = PrimaryButtonViewModelMocking(buttonStyle: .primaryFilled,
                                                                              buttonLabel: "buttonLabel",
                                                                              updateState: updateJoinCallButtonViewModel)
        let sut = makeSUT()
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_receive_when_appStateUpdated_then_errorInfoViewModelUpdated() {
        let appState = AppState()
        let expectation = XCTestExpectation(description: "ErrorInfoViewModel is updated")
        let updateErrorInfoViewModel: ((ErrorState) -> Void) = { errorState in
            XCTAssertEqual(errorState, appState.errorState)
            expectation.fulfill()
        }
        factoryMocking.errorInfoViewModel = ErrorInfoViewModelMocking(updateState: updateErrorInfoViewModel)
        let sut = makeSUT()
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
    }
}

extension SetupViewModelTests {
    func getCallingState(_ statue: CallingStatus = .none) -> CallingState {
        return CallingState(status: statue,
                            isRecordingActive: false,
                            isTranscriptionActive: false)
    }

    func makeSUT() -> SetupViewModel {
        return SetupViewModel(compositeViewModelFactory: factoryMocking,
                              logger: logger,
                              store: storeFactory.store,
                              networkManager: NetworkManager(),
                              audioSessionManager: AudioSessionManager(store: storeFactory.store, logger: logger),
                              localizationProvider: LocalizationProviderMocking())
    }
}

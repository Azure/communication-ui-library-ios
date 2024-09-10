//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
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
                                                          store: storeFactory.store,
                                                          avatarManager: AvatarViewManagerMocking(store: storeFactory.store,
                                                                                                  localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                                                                  localParticipantViewData: nil),
                                                          updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil))
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        cancellable = nil
        logger = nil
        factoryMocking = nil
    }

    func test_setupViewModel_when_joinCallButtonTapped_then_shouldCallStartRequest_isJoinRequestedTrue() {
        let expectation = XCTestExpectation(description: "Verify Last Action is Calling View Launched")
        let sut = makeSUT()

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 2)
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
        let updatePreviewAreaViewModel: ((LocalUserState, PermissionState, VisibilityState) -> Void) = { userState, permissionsState, _ in
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
        let updateSetupControlBarViewModel: ((LocalUserState, PermissionState, CallingState, ButtonViewDataState) -> Void) = { userState, permissionsState, callingState, buttonViewDataState in
            XCTAssertEqual(userState.displayName, appState.localUserState.displayName)
            XCTAssertEqual(permissionsState.audioPermission, appState.permissionState.audioPermission)
            XCTAssertEqual(callingState, appState.callingState)
            XCTAssertEqual(buttonViewDataState, appState.buttonViewDataState)
            expectation.fulfill()
        }
        factoryMocking.setupControlBarViewModel = SetupControlBarViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                                  logger: logger,
                                                                                  dispatchAction: storeFactory.store.dispatch,
                                                                                  updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil),
                                                                                  localUserState: LocalUserState(),
                                                                                  buttonViewDataState: ButtonViewDataState(),
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
                                                                       updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil),
                                                                       localUserState: LocalUserState(),
                                                                       buttonViewDataState: ButtonViewDataState())
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

    func test_setupViewModel_receive_when_appStateUpdated_then_startCallButtonViewModelUpdated() {
        let appState = AppState()
        let expectation = XCTestExpectation(description: "StartCallButtonViewModel is updated")
        var stringList: [String?] = []
        let updateJoinCallButtonViewModel: ((String?) -> Void) = { accessibilityLabel in
            stringList.append(accessibilityLabel)
            expectation.fulfill()
        }
        factoryMocking.primaryButtonViewModel = PrimaryButtonViewModelMocking(buttonStyle: .primaryFilled,
                                                                              buttonLabel: "buttonLabel",
                                                                              updateLabel: updateJoinCallButtonViewModel)
        let sut = makeSUT(callType: .oneToNOutgoing)
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(true, stringList.contains(LocalizationKey.startCall.rawValue))
    }

    func test_setupViewModel_receive_when_appStateUpdated_then_joinCallButtonViewModelLabelUpdated() {
        let appState = AppState()
        let expectation = XCTestExpectation(description: "JoinCallButtonViewModel is updated")
        var stringList: [String?] = []
        let updateJoinCallButtonViewModel: ((String?) -> Void) = { accessibilityLabel in
            stringList.append(accessibilityLabel)
            expectation.fulfill()
        }
        factoryMocking.primaryButtonViewModel = PrimaryButtonViewModelMocking(buttonStyle: .primaryFilled,
                                                                              buttonLabel: "buttonLabel",
                                                                              updateLabel: updateJoinCallButtonViewModel)
        let sut = makeSUT(callType: .groupCall)
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(true, stringList.contains(LocalizationKey.joinCall.rawValue))
    }

    func test_setupViewModel_receive_when_appStateUpdatedWithNoAudioPermissions_then_startCallButtonViewModelUpdated() {
        let appState = AppState(permissionState: PermissionState(audioPermission: .denied))
        let expectation = XCTestExpectation(description: "StartCallButtonViewModel is updated")
        var stringList: [String?] = []
        let updateJoinCallButtonViewModel: ((String?) -> Void) = { accessibilityLabel in
            stringList.append(accessibilityLabel)
            expectation.fulfill()
        }
        factoryMocking.primaryButtonViewModel = PrimaryButtonViewModelMocking(buttonStyle: .primaryFilled,
                                                                              buttonLabel: "buttonLabel",
                                                                              isDisabled: true,
                                                                              updateLabel: updateJoinCallButtonViewModel)
        let sut = makeSUT(callType: .oneToNOutgoing)
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(true, stringList.contains(LocalizationKey.startCallDiableStateAccessibilityLabel.rawValue))
    }

    func test_setupViewModel_receive_when_appStateUpdatedWithNoAudioPermissions_then_joinCallButtonViewModelLabelUpdated() {
        let appState = AppState(permissionState: PermissionState(audioPermission: .denied))
        let expectation = XCTestExpectation(description: "JoinCallButtonViewModel is updated")
        var stringList: [String?] = []
        let updateJoinCallButtonViewModel: ((String?) -> Void) = { accessibilityLabel in
            stringList.append(accessibilityLabel)
            expectation.fulfill()
        }
        factoryMocking.primaryButtonViewModel = PrimaryButtonViewModelMocking(buttonStyle: .primaryFilled,
                                                                              buttonLabel: "buttonLabel",
                                                                              isDisabled: true,
                                                                              updateLabel: updateJoinCallButtonViewModel)
        let sut = makeSUT(callType: .groupCall)
        sut.receive(appState)
        wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(true, stringList.contains(LocalizationKey.joinCallDiableStateAccessibilityLabel.rawValue))
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

    func makeSUT(callType: CompositeCallType = .groupCall) -> SetupViewModel {
        return SetupViewModel(compositeViewModelFactory: factoryMocking,
                              logger: logger,
                              store: storeFactory.store,
                              networkManager: NetworkManager(),
                              audioSessionManager: AudioSessionManager(store: storeFactory.store, logger: logger, isCallKitEnabled: false),
                              localizationProvider: LocalizationProviderMocking(),
                              callType: callType)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class SetupControlBarViewModelTests: XCTestCase {
    private var storeFactory: StoreFactoryMocking!
    private var factoryMocking: CompositeVmButtonFactoryMocking!
    private var cancellable: CancelBag!
    private var logger: LoggerMocking!
    private var localizationProvider: LocalizationProviderMocking!

    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        logger = LoggerMocking()
        localizationProvider = LocalizationProviderMocking()
        factoryMocking = CompositeVmButtonFactoryMocking(logger: logger,
                                                          store: storeFactory.store)
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        cancellable = nil
        logger = nil
        localizationProvider = nil
        factoryMocking = nil
    }

    func test_setupControlBarViewModel_when_videoButtonTapped_then_requestCameraOnIfPreviouslyOff() {
        let expectation = XCTestExpectation(description: "Verify Camera On")
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(cameraPermission: .granted),
                                            localUserState: LocalUserState(cameraState: cameraState))
        sut.update(localUserState: storeFactory.store.state.localUserState,
                                        permissionState: storeFactory.store.state.permissionState,
                                        callingState: CallingState())

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last == Action.localUserAction(.cameraPreviewOnTriggered))

                expectation.fulfill()
            }.store(in: cancellable)

        sut.videoButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_videoButtonTapped_then_requestCameraOffIfPreviouslyOn() {
        let expectation = XCTestExpectation(description: "Verify Camera Off")
        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(cameraPermission: .granted),
                                            localUserState: LocalUserState(cameraState: cameraState))
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   permissionState: storeFactory.store.state.permissionState,
                   callingState: CallingState())

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last == Action.localUserAction(.cameraOffTriggered))

                expectation.fulfill()
            }.store(in: cancellable)

        sut.videoButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_micButtonTapped_then_requestMicPreviewOnIfPreviouslyOff() {
        let expectation = XCTestExpectation(description: "Verify Mic Preview On")
        let audioState = LocalUserState.AudioState(operation: .off,
                                                   device: .receiverSelected)
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted),
                                            localUserState: LocalUserState(audioState: audioState))
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   permissionState: storeFactory.store.state.permissionState,
                   callingState: CallingState.init())

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last == Action.localUserAction(.microphonePreviewOn))

                expectation.fulfill()
            }.store(in: cancellable)

        sut.microphoneButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_micButtonTapped_then_requestMicPreviewOffIfPreviouslyOn() {
        let expectation = XCTestExpectation(description: "Verify Mic Preview Off")
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted),
                                            localUserState: LocalUserState(audioState: audioState))
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   permissionState: storeFactory.store.state.permissionState,
                   callingState: CallingState())

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last == Action.localUserAction(.microphonePreviewOff))

                expectation.fulfill()
            }.store(in: cancellable)

        sut.microphoneButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_selectAudioDeviceButtonTapped_then_audioDeviceSelectionDisplayed() {
        let sut = makeSUT()
        sut.selectAudioDeviceButtonTapped()

        XCTAssertTrue(sut.isAudioDeviceSelectionDisplayed)
    }

    func test_setupControlBarViewModel_when_audioPermissionDenied_then_hideSetupControlBar() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                             cameraPermission: .granted),
                                            localUserState: LocalUserState(cameraState: cameraState))
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   permissionState: storeFactory.store.state.permissionState,
                   callingState: CallingState())

        XCTAssertTrue(sut.isControlBarHidden())
    }

    func test_setupControlBarViewModel_when_cameraPermissionDenied_then_disableCameraButton() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                             cameraPermission: .denied),
                                            localUserState: LocalUserState(cameraState: cameraState))
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   permissionState: storeFactory.store.state.permissionState,
                   callingState: CallingState())

        XCTAssertFalse(sut.isAudioDisabled())
        XCTAssertTrue(sut.isCameraDisabled())
    }

    func test_setupControlBarViewModel_when_updateJoinRequestedTrue_then_buttonViewModelsUpdateDisabled() {
        let expectation = XCTestExpectation(description: "CameraButtonViewModel disabled state is updated")
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                             cameraPermission: .granted),
                                            localUserState: LocalUserState())
        let updateDisabledStateCompletion: ((Bool) -> Void) = { isDisabled in
            XCTAssertEqual(isDisabled, true)
            expectation.fulfill()
        }
        factoryMocking.createCameraIconWithLabelButtonViewModel = { buttonState in
            guard buttonState == .videoOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(
                selectedButtonState: CameraState.videoOff,
                localizationProvider: self.localizationProvider,
                buttonTypeColor: .colorThemedWhite)
            iconWithLabelButtonViewModel.updateDisabledState = updateDisabledStateCompletion
            return iconWithLabelButtonViewModel
        }
        let sut = makeSUT()
        sut.update(isJoinRequested: true)
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_updateJoinRequestedTure_then_audioAndVideoAreDisabled() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                             cameraPermission: .granted),
                                            localUserState: LocalUserState(cameraState: cameraState))
        sut.update(isJoinRequested: true)

        XCTAssertTrue(sut.isCameraDisabled())
        XCTAssertTrue(sut.isAudioDisabled())
    }

    func test_setupControlBarViewModel_when_updateJoinRequestedFalse_AudioAndVideoAreDenied_then_audioAndVideoAreDisabled() {
        let sut = makeSUT()
        sut.update(localUserState: LocalUserState(),
                   permissionState: PermissionState(audioPermission: .denied,
                                                    cameraPermission: .denied),
                   callingState: CallingState())
        sut.update(isJoinRequested: false)

        XCTAssertTrue(sut.isCameraDisabled())
        XCTAssertTrue(sut.isAudioDisabled())
    }

    func test_setupControlBarViewModel_when_updateJoinRequestedFalse_AudioAndVideoAreGranted_then_audioAndVideoAreDisabled() {
        let sut = makeSUT()
        sut.update(localUserState: LocalUserState(),
                   permissionState: PermissionState(audioPermission: .granted,
                                                    cameraPermission: .granted),
                   callingState: CallingState())
        sut.update(isJoinRequested: false)

        XCTAssertFalse(sut.isCameraDisabled())
        XCTAssertFalse(sut.isAudioDisabled())
    }

    func test_setupControlBarViewModel_when_microphoneDefaultState_then_defaultToOff() {
        let sut = makeSUT()
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted),
                                            localUserState: LocalUserState())
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   permissionState: storeFactory.store.state.permissionState,
                   callingState: CallingState())

        XCTAssertEqual(sut.micStatus, .off)
    }

    func test_setupControlBarViewModel_updateStates_when_stateUpdated_then_cameraButtonViewModelButtonInfoUpdated() {
        let expectation = XCTestExpectation(description: "CameraButtonViewModel button info is updated")
        let updateButtonInfoCompletion: ((CameraState) -> Void) = { buttonState in
            XCTAssertEqual(buttonState.iconName, .videoOn)
            XCTAssertEqual(buttonState.localizationKey, .videoOn)
            expectation.fulfill()
        }
        factoryMocking.createCameraIconWithLabelButtonViewModel = { buttonState in
            guard buttonState == .videoOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(
                selectedButtonState: CameraState.videoOff,
                localizationProvider: self.localizationProvider,
                buttonTypeColor: .colorThemedWhite)
            iconWithLabelButtonViewModel.updateButtonInfo = updateButtonInfoCompletion
            return iconWithLabelButtonViewModel
        }
        let localUserState = LocalUserState(cameraState: LocalUserState.CameraState(operation: .on,
                                                                                    device: .front,
                                                                                    transmission: .local))
        let sut = makeSUT()
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_updateStates_when_stateUpdated_then_cameraButtonViewModelDisabledStateUpdated() {
        let expectation = XCTestExpectation(description: "CameraButtonViewModel disabled state is updated")
        let permissionState = PermissionState()
        let updateDisabledStateCompletion: ((Bool) -> Void) = { isDisabled in
            XCTAssertEqual(isDisabled, permissionState.cameraPermission == .denied)
            expectation.fulfill()
        }
        factoryMocking.createCameraIconWithLabelButtonViewModel = { buttonState in
            guard buttonState == .videoOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(
                selectedButtonState: CameraState.videoOff,
                localizationProvider: self.localizationProvider,
                buttonTypeColor: .colorThemedWhite)
            iconWithLabelButtonViewModel.updateDisabledState = updateDisabledStateCompletion
            return iconWithLabelButtonViewModel
        }
        let sut = makeSUT()
        sut.update(localUserState: LocalUserState(),
                   permissionState: permissionState,
                   callingState: CallingState())
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_updateStates_when_stateUpdated_then_micButtonViewModelButtonInfoUpdated() {
        let expectation = XCTestExpectation(description: "MicButtonViewModel button info is updated")
        let updateButtonInfoCompletion: ((MicState) -> Void) = { buttonState in
            XCTAssertEqual(buttonState.iconName, .micOn)
            XCTAssertEqual(buttonState.localizationKey, .micOn)
            expectation.fulfill()
        }

        factoryMocking.createMicIconWithLabelButtonViewModel = { buttonState in
            guard buttonState == .micOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(
                selectedButtonState: MicState.micOff,
                localizationProvider: self.localizationProvider,
                buttonTypeColor: .colorThemedWhite)
            iconWithLabelButtonViewModel.updateButtonInfo = updateButtonInfoCompletion
            return iconWithLabelButtonViewModel
        }
        let localUserState = LocalUserState(audioState: LocalUserState.AudioState(operation: .on, device: .receiverSelected))
        let sut = makeSUT()
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_updateStates_when_stateUpdated_then_audioDeviceButtonViewModelButtonInfoUpdated() {
        let expectation = XCTestExpectation(description: "AudioDeviceButtonViewModel button info is updated")
        let updateButtonInfoCompletion: ((AudioState) -> Void) = { buttonState in
            XCTAssertEqual(buttonState.iconName, .speakerFilled)
            XCTAssertEqual(buttonState.localizationKey, .speaker)
            expectation.fulfill()
        }
        factoryMocking.createAudioIconWithLabelButtonViewModel = { buttonState in
            guard buttonState == .speaker
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(
                selectedButtonState: AudioState.bluetooth,
                localizationProvider: self.localizationProvider,
                buttonTypeColor: .colorThemedWhite)
            iconWithLabelButtonViewModel.updateButtonInfo = updateButtonInfoCompletion
            return iconWithLabelButtonViewModel
        }
        let localUserState = LocalUserState(audioState: LocalUserState.AudioState(operation: .on, device: .speakerSelected))
        let sut = makeSUT()
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_updateStates_when_stateUpdated_then_audioDeviceListViewModelUpdated() {
        let expectation = XCTestExpectation(description: "AudioDevicesListViewModel is updated")
        let localUserState = LocalUserState(audioState: LocalUserState.AudioState(operation: .on, device: .speakerSelected))
        let audioDevicesListViewModel = AudioDevicesListViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                         dispatchAction: storeFactory.store.dispatch,
                                                                         localUserState: localUserState,
                                                                         localizationProvider: localizationProvider)

        audioDevicesListViewModel.updateState = { status in
            XCTAssertEqual(status, localUserState.audioState.device)
            expectation.fulfill()
        }
        factoryMocking.audioDevicesListViewModel = audioDevicesListViewModel
        let sut = makeSUT()
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_display_videoButtonLabel__from_LocalizationMocking() {
        let expectation = XCTestExpectation(description: "CameraButtonViewModel button info is updated")
        let updateButtonInfoCompletion: ((CameraState) -> Void) = { buttonState in
            XCTAssertEqual(buttonState.iconName, .videoOn)
            XCTAssertEqual(buttonState.localizationKey, .videoOn)
            expectation.fulfill()
        }
        factoryMocking.createCameraIconWithLabelButtonViewModel = { buttonState in
            guard buttonState == .videoOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(
                selectedButtonState: CameraState.videoOn,
                localizationProvider: self.localizationProvider,
                buttonTypeColor: .colorThemedWhite)
            iconWithLabelButtonViewModel.updateButtonInfo = updateButtonInfoCompletion
            return iconWithLabelButtonViewModel
        }
        let localUserState = LocalUserState(cameraState: LocalUserState.CameraState(operation: .on,
                                                                                    device: .front,
                                                                                    transmission: .local))
        let sut = makeSUTLocalizationMocking()
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: timeout)
    }
}

extension SetupControlBarViewModelTests {
    func makeSUT() -> SetupControlBarViewModel {
        return SetupControlBarViewModel(compositeViewModelFactory: factoryMocking,
                                        logger: logger,
                                        dispatchAction: storeFactory.store.dispatch,
                                        localUserState: LocalUserState(),
                                        localizationProvider: LocalizationProvider(logger: logger))
    }

    func makeSUTLocalizationMocking() -> SetupControlBarViewModel {
        return SetupControlBarViewModel(compositeViewModelFactory: factoryMocking,
                                        logger: logger,
                                        dispatchAction: storeFactory.store.dispatch,
                                        localUserState: LocalUserState(),
                                        localizationProvider: localizationProvider)
    }
}

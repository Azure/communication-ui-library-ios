//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class SetupControlBarViewModelTests: XCTestCase {
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
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.CameraPreviewOnTriggered)

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
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.CameraOffTriggered)

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
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.MicrophonePreviewOn)

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
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.MicrophonePreviewOff)

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

        XCTAssertTrue(sut.isAudioDisabled())
        XCTAssertFalse(sut.isCameraDisabled())
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
        let updateButtonInfoCompletion: ((CompositeIcon, String) -> Void) = { icon, label in
            XCTAssertEqual(icon, .videoOn)
            XCTAssertEqual(label, "Video is on")
            expectation.fulfill()
        }
        factoryMocking.createIconWithLabelButtonViewModel = { icon in
            guard icon == .videoOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(iconName: .clock,
                                                                                   buttonTypeColor: .colorThemedWhite,
                                                                                   buttonLabel: "buttonLabel")
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
        factoryMocking.createIconWithLabelButtonViewModel = { icon in
            guard icon == .videoOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(iconName: .clock,
                                                                                   buttonTypeColor: .colorThemedWhite,
                                                                                   buttonLabel: "buttonLabel")
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
        let updateButtonInfoCompletion: ((CompositeIcon, String) -> Void) = { icon, label in
            XCTAssertEqual(icon, .micOn)
            XCTAssertEqual(label, "Mic is on")
            expectation.fulfill()
        }
        factoryMocking.createIconWithLabelButtonViewModel = { icon in
            guard icon == .micOff
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(iconName: .clock,
                                                                                   buttonTypeColor: .colorThemedWhite,
                                                                                   buttonLabel: "buttonLabel")
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
        let updateButtonInfoCompletion: ((CompositeIcon, String) -> Void) = { icon, label in
            XCTAssertEqual(icon, .speakerFilled)
            XCTAssertEqual(label, "Speaker")
            expectation.fulfill()
        }
        factoryMocking.createIconWithLabelButtonViewModel = { icon in
            guard icon == .speakerFilled
            else { return nil }

            let iconWithLabelButtonViewModel = IconWithLabelButtonViewModelMocking(iconName: .clock,
                                                                                   buttonTypeColor: .colorThemedWhite,
                                                                                   buttonLabel: "buttonLabel")
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
        let expectation = XCTestExpectation(description: "AudioDeviceListViewModel is updated")
        let localUserState = LocalUserState(audioState: LocalUserState.AudioState(operation: .on, device: .speakerSelected))
        let audioDeviceListViewModel = AudioDeviceListViewModelMocking(dispatchAction: storeFactory.store.dispatch,
                                                                       localUserState: localUserState)
        audioDeviceListViewModel.updateState = { status in
            XCTAssertEqual(status, localUserState.audioState.device)
            expectation.fulfill()
        }
        factoryMocking.audioDeviceListViewModel = audioDeviceListViewModel
        let sut = makeSUT()
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
                                        localUserState: LocalUserState())
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class SetupControlBarViewModelTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!

    var setupControlBarViewModel: SetupControlBarViewModel!
    private let timeout: TimeInterval = 10.0

    override func setUp() {
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        let logger = LoggerMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        setupControlBarViewModel = SetupControlBarViewModel(compositeViewModelFactory: factoryMocking,
                                              logger: logger,
                                              dispatchAction: storeFactory.store.dispatch,
                                              localUserState: LocalUserState())
    }

    func test_setupControlBarViewModel_when_videoButtonTapped_then_requestCameraOnIfPreviouslyOff() {
        let expectation = XCTestExpectation(description: "Verify Camera On")
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        storeFactory.store.state = AppState(permissionState: PermissionState(cameraPermission: .granted),
                                            localUserState: LocalUserState(cameraState: cameraState))
        setupControlBarViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                        permissionState: storeFactory.store.state.permissionState)

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.CameraPreviewOnTriggered)

                expectation.fulfill()
            }.store(in: cancellable)

        setupControlBarViewModel.videoButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_videoButtonTapped_then_requestCameraOffIfPreviouslyOn() {
        let expectation = XCTestExpectation(description: "Verify Camera Off")
        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        storeFactory.store.state = AppState(permissionState: PermissionState(cameraPermission: .granted),
                                            localUserState: LocalUserState(cameraState: cameraState))
        setupControlBarViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                 permissionState: storeFactory.store.state.permissionState)

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.CameraOffTriggered)

                expectation.fulfill()
            }.store(in: cancellable)

        setupControlBarViewModel.videoButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_micButtonTapped_then_requestMicPreviewOnIfPreviouslyOff() {
        let expectation = XCTestExpectation(description: "Verify Mic Preview On")
        let audioState = LocalUserState.AudioState(operation: .off,
                                                    device: .receiverSelected)
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted),
                                            localUserState: LocalUserState(audioState: audioState))
        setupControlBarViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                 permissionState: storeFactory.store.state.permissionState)

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.MicrophonePreviewOn)

                expectation.fulfill()
            }.store(in: cancellable)

        setupControlBarViewModel.microphoneButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_micButtonTapped_then_requestMicPreviewOffIfPreviouslyOn() {
        let expectation = XCTestExpectation(description: "Verify Mic Preview Off")
        let audioState = LocalUserState.AudioState(operation: .on,
                                                    device: .receiverSelected)
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted),
                                            localUserState: LocalUserState(audioState: audioState))
        setupControlBarViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                 permissionState: storeFactory.store.state.permissionState)

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is LocalUserAction.MicrophonePreviewOff)

                expectation.fulfill()
            }.store(in: cancellable)

        setupControlBarViewModel.microphoneButtonTapped()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupControlBarViewModel_when_selectAudioDeviceButtonTapped_then_audioDeviceSelectionDisplayed() {
        setupControlBarViewModel.selectAudioDeviceButtonTapped()

        XCTAssertTrue(setupControlBarViewModel.isAudioDeviceSelectionDisplayed)
    }

    func test_setupControlBarViewModel_when_audioPermissionDenied_then_hideSetupControlBar() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                             cameraPermission: .granted),
                                            localUserState: LocalUserState(cameraState: cameraState))
        setupControlBarViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                 permissionState: storeFactory.store.state.permissionState)

        XCTAssertTrue(setupControlBarViewModel.isAudioDisabled())
        XCTAssertFalse(setupControlBarViewModel.isCameraDisabled())
    }

    func test_setupControlBarViewModel_when_cameraPermissionDenied_then_disableCameraButton() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                             cameraPermission: .denied),
                                            localUserState: LocalUserState(cameraState: cameraState))
        setupControlBarViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                 permissionState: storeFactory.store.state.permissionState)

        XCTAssertFalse(setupControlBarViewModel.isAudioDisabled())
        XCTAssertTrue(setupControlBarViewModel.isCameraDisabled())
    }

    func test_setupControlBarViewModel_when_microphoneDefaultState_then_defaultToOff() {
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .granted),
                                            localUserState: LocalUserState())
        setupControlBarViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                 permissionState: storeFactory.store.state.permissionState)

        XCTAssertEqual(setupControlBarViewModel.micStatus, .off)
    }
}

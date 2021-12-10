//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class ControlBarViewModelTests: XCTestCase {

    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var controlBarViewModel: ControlBarViewModel!

    override func setUp() {
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()


        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        controlBarViewModel = ControlBarViewModel(compositeViewModelFactory: factoryMocking,
                                                  logger: LoggerMocking(),
                                                  dispatchAction: dispatch,
                                                  endCallConfirm: {},
                                                  localUserState: LocalUserState())
    }

    // MARK: Microphone tests
    func test_controlBarViewModel_microphoneButtonTapped_when_micStatusOff_then_shouldMicrophoneOnRequested() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.audioState = LocalUserState.AudioState(operation: .off,
                                                                   device: .receiverSelected)

        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first is LocalUserAction.MicrophoneOnTriggered)
                expectation.fulfill()
            }.store(in: cancellable)
        controlBarViewModel.microphoneButtonTapped()

        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_microphoneButtonTapped_when_micStatusOn_then_shouldMicrophoneOffRequested() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)

        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first is LocalUserAction.MicrophoneOffTriggered)
                expectation.fulfill()
            }.store(in: cancellable)
        controlBarViewModel.microphoneButtonTapped()

        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOffAndUpdateWithMicOff_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        controlBarViewModel.micButtonViewModel.$iconName
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Mic was .off and update with .off should not publish")
            }).store(in: cancellable)
        let audioState = LocalUserState.AudioState(operation: .off,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .off)
        XCTAssertEqual(controlBarViewModel.micButtonViewModel.iconName, .micOff)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusOffAndUpdateWithMicSwitching_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.micButtonViewModel.$isDisabled
            .dropFirst()
            .sink(receiveValue: { isDisabled in
                XCTAssertEqual(isDisabled, true)
                expectation.fulfill()
            }).store(in: cancellable)
        let audioState = LocalUserState.AudioState(operation: .pending,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)

        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .pending)
        XCTAssertEqual(controlBarViewModel.isMicDisabled(), true)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusOnAndUpdateWithMicSwitching_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.micButtonViewModel.$isDisabled
            .dropFirst()
            .sink(receiveValue: { isDisabled in
                XCTAssertEqual(isDisabled, true)
                expectation.fulfill()
            }).store(in: cancellable)

        controlBarViewModel.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)

        let audioState = LocalUserState.AudioState(operation: .pending,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)

        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .pending)
        XCTAssertEqual(controlBarViewModel.isMicDisabled(), true)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusSwitchingAndUpdateWithMicOn_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.micButtonViewModel.$isDisabled
            .dropFirst(2)
            .sink(receiveValue: { isDisabled in
                XCTAssertEqual(isDisabled, false)
                expectation.fulfill()
            }).store(in: cancellable)

        controlBarViewModel.audioState = LocalUserState.AudioState(operation: .pending,
                                                                   device: .receiverSelected)
        controlBarViewModel.micButtonViewModel.update(isDisabled: controlBarViewModel.isMicDisabled())

        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)

        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .on)
        XCTAssertEqual(controlBarViewModel.isMicDisabled(), false)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusSwitchingAndUpdateWithMicOff_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.micButtonViewModel.$isDisabled
            .dropFirst(2)
            .sink(receiveValue: { isDisabled in
                XCTAssertEqual(isDisabled, false)
                expectation.fulfill()
            }).store(in: cancellable)

        controlBarViewModel.audioState = LocalUserState.AudioState(operation: .pending,
                                                                   device: .receiverSelected)
        controlBarViewModel.micButtonViewModel.update(isDisabled: controlBarViewModel.isMicDisabled())
        let audioState = LocalUserState.AudioState(operation: .off,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)

        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .off)
        XCTAssertEqual(controlBarViewModel.isMicDisabled(), false)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOffAndUpdateWithMicOn_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.micButtonViewModel.$iconName
            .dropFirst()
            .sink(receiveValue: { iconName in
                XCTAssertEqual(iconName, .micOn)
                expectation.fulfill()
            }).store(in: cancellable)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .on)
        XCTAssertEqual(controlBarViewModel.isMicDisabled(), false)
        XCTAssertEqual(controlBarViewModel.micButtonViewModel.iconName, .micOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOnAndUpdateWithMicOon_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        controlBarViewModel.micButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Mic was .on and update with .on should not publish")
            }).store(in: cancellable)
        controlBarViewModel.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)
        controlBarViewModel.micButtonViewModel.iconName = .micOn
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .on)
        XCTAssertEqual(controlBarViewModel.isMicDisabled(), false)
        XCTAssertEqual(controlBarViewModel.micButtonViewModel.iconName, .micOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOnAndUpdateWithMicOff_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.micButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { iconName in
                XCTAssertEqual(iconName, .micOff)
                expectation.fulfill()
            }).store(in: cancellable)
        controlBarViewModel.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)
        controlBarViewModel.micButtonViewModel.iconName = .micOn
        let audioState = LocalUserState.AudioState(operation: .off,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.audioState.operation, .off)
        XCTAssertEqual(controlBarViewModel.isMicDisabled(), false)
        XCTAssertEqual(controlBarViewModel.micButtonViewModel.iconName, .micOff)
        wait(for: [expectation], timeout: 1)
    }

    // MARK: Camera tests
    func test_controlBarViewModel_cameraButtonTapped_when_cameraStatusOff_then_shouldRequestCameraOnTriggered() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first is LocalUserAction.CameraOnTriggered)
                expectation.fulfill()
            }.store(in: cancellable)
        controlBarViewModel.cameraState = LocalUserState.CameraState(operation: .off,
                                                                     device: .front,
                                                                     transmission: .local)
        controlBarViewModel.cameraButtonTapped()
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_cameraButtonTapped_when_cameraStatusOn_then_shouldRequestCameraOffTriggered() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first is LocalUserAction.CameraOffTriggered)
                expectation.fulfill()
            }.store(in: cancellable)
        controlBarViewModel.cameraState = LocalUserState.CameraState(operation: .on,
                                                                     device: .front,
                                                                     transmission: .local)
        controlBarViewModel.cameraButtonTapped()
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_when_selectAudioDeviceButtonTapped_then_audioDeviceSelectionDisplayed() {
        controlBarViewModel.selectAudioDeviceButtonTapped()

        XCTAssertTrue(controlBarViewModel.isAudioDeviceSelectionDisplayed)
    }

    func test_controlBarViewModel_update_when_cameraStatusOffAndUpdateWithCameraOff_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        controlBarViewModel.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Camera was .on and update with .on should not publish")
            }).store(in: cancellable)
        controlBarViewModel.cameraState = LocalUserState.CameraState(operation: .off,
                                                                     device: .front,
                                                                     transmission: .local)
        controlBarViewModel.cameraButtonViewModel.iconName = .videoOff
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.cameraState.operation, .off)
        XCTAssertEqual(controlBarViewModel.cameraButtonViewModel.iconName, .videoOff)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_cameraStatusOffAndUpdateWithCameraOn_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { iconName in
                XCTAssertEqual(iconName, .videoOn)
                expectation.fulfill()
            }).store(in: cancellable)
        controlBarViewModel.cameraState = LocalUserState.CameraState(operation: .off,
                                                                     device: .front,
                                                                     transmission: .local)
        controlBarViewModel.cameraButtonViewModel.iconName = .videoOff

        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.cameraState.operation, .on)
        XCTAssertEqual(controlBarViewModel.cameraButtonViewModel.iconName, .videoOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_cameraStatusOnAndUpdateWithCameraOn_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        controlBarViewModel.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Camera was .on and update with .on should not publish")
            }).store(in: cancellable)
        controlBarViewModel.cameraState = LocalUserState.CameraState(operation: .on,
                                                                     device: .front,
                                                                     transmission: .local)
        controlBarViewModel.cameraButtonViewModel.iconName = .videoOn

        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.cameraState.operation, .on)
        XCTAssertEqual(controlBarViewModel.cameraButtonViewModel.iconName, .videoOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_cameraStatusOnAndUpdateWithCameraOff_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        controlBarViewModel.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { iconName in
                XCTAssertEqual(iconName, .videoOff)
                expectation.fulfill()
            }).store(in: cancellable)
        controlBarViewModel.cameraState = LocalUserState.CameraState(operation: .on,
                                                                     device: .front,
                                                                     transmission: .local)
        controlBarViewModel.cameraButtonViewModel.iconName = .videoOn

        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        controlBarViewModel.update(localUserState: localUserState, permissionState: permissionState)
        XCTAssertEqual(controlBarViewModel.cameraState.operation, .off)
        XCTAssertEqual(controlBarViewModel.cameraButtonViewModel.iconName, .videoOff)
        wait(for: [expectation], timeout: 1)
    }
}

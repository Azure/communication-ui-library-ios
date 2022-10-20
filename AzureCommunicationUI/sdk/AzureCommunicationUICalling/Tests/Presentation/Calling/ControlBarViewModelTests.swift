//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class ControlBarViewModelTests: XCTestCase {

    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var localizationProvider: LocalizationProviderMocking!
    var logger: LoggerMocking!
    var factoryMocking: CompositeViewModelFactoryMocking!

    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        cancellable = nil
        localizationProvider = nil
        logger = nil
        factoryMocking = nil
    }

    // MARK: Leave Call / Cancel test
    func test_controlBarViewModel_getLeaveCallButtonViewModel_shouldReturnLeaveCallButtonViewModel() {
        let sut = makeSUT()
        let leaveCallButtonViewModel = sut.getLeaveCallButtonViewModel()
        let expectedButtonLabel = "Leave"

        XCTAssertEqual(leaveCallButtonViewModel.title, expectedButtonLabel)
    }

    func test_controlBarViewModel_getLeaveCallButtonViewModel_shouldReturnCancelButtonViewModel() {
        let sut = makeSUT()
        let leaveCallButtonViewModel = sut.getCancelButtonViewModel()
        let expectedButtonLabel = "Cancel"

        XCTAssertEqual(leaveCallButtonViewModel.title, expectedButtonLabel)
    }

    func test_controlBarViewModel_CancellButtonLabel_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        let cancelButtonViewModel = sut.getCancelButtonViewModel()
        let expectedButtonLabelKey = "AzureCommunicationUICalling.CallingView.Overlay.Cancel"

        XCTAssertEqual(cancelButtonViewModel.title, expectedButtonLabelKey)
        XCTAssertTrue(localizationProvider.isGetLocalizedStringCalled)
    }

    func test_controlBarViewModel_leaveCallButtonLabel_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        let leaveCallButtonViewModel = sut.getLeaveCallButtonViewModel()
        let expectedButtonLabelKey = "AzureCommunicationUICalling.CallingView.Overlay.LeaveCall"

        XCTAssertEqual(leaveCallButtonViewModel.title, expectedButtonLabelKey)
        XCTAssertTrue(localizationProvider.isGetLocalizedStringCalled)
    }

    func test_controlBarViewModel_dismissConfirmLeaveOverlay_when_isConfirmLeaveListDisplayedTrue_shouldBecomeFalse() {
        let sut = makeSUT()
        sut.isConfirmLeaveListDisplayed = true
        sut.dismissConfirmLeaveDrawerList()

        XCTAssertFalse(sut.isConfirmLeaveListDisplayed)
    }

    func test_controlBarViewModel_endCall_when_confirmLeaveListIsDisplayed_shouldBecomeTrue() {
        let sut = makeSUT()
        sut.isConfirmLeaveListDisplayed = false
        sut.endCallButtonTapped()
        XCTAssertTrue(sut.isConfirmLeaveListDisplayed)
    }

    // MARK: Microphone tests
    func test_controlBarViewModel_microphoneButtonTapped_when_micStatusOff_then_shouldMicrophoneOnRequested() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.audioState = LocalUserState.AudioState(operation: .off,
                                                                   device: .receiverSelected)

        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .localUserAction(.microphoneOnTriggered))
                expectation.fulfill()
            }.store(in: cancellable)
        sut.microphoneButtonTapped()

        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_microphoneButtonTapped_when_micStatusOn_then_shouldMicrophoneOffRequested() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)

        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .localUserAction(.microphoneOffTriggered))
                expectation.fulfill()
            }.store(in: cancellable)
        sut.microphoneButtonTapped()

        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOffAndUpdateWithMicOff_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        sut.micButtonViewModel.$iconName
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
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .off)
        XCTAssertEqual(sut.micButtonViewModel.iconName, .micOff)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusOffAndUpdateWithMicSwitching_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.micButtonViewModel.$isDisabled
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

        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .pending)
        XCTAssertEqual(sut.isMicDisabled(), true)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusOnAndUpdateWithMicSwitching_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.micButtonViewModel.$isDisabled
            .dropFirst()
            .sink(receiveValue: { isDisabled in
                XCTAssertEqual(isDisabled, true)
                expectation.fulfill()
            }).store(in: cancellable)

        sut.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)

        let audioState = LocalUserState.AudioState(operation: .pending,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)

        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .pending)
        XCTAssertEqual(sut.isMicDisabled(), true)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusSwitchingAndUpdateWithMicOn_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.micButtonViewModel.$isDisabled
            .dropFirst(2)
            .sink(receiveValue: { isDisabled in
                XCTAssertEqual(isDisabled, false)
                expectation.fulfill()
            }).store(in: cancellable)

        sut.audioState = LocalUserState.AudioState(operation: .pending,
                                                                   device: .receiverSelected)
        sut.micButtonViewModel.update(isDisabled: sut.isMicDisabled())

        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)

        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .on)
        XCTAssertEqual(sut.isMicDisabled(), false)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_micStatusSwitchingAndUpdateWithMicOff_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.micButtonViewModel.$isDisabled
            .dropFirst(2)
            .sink(receiveValue: { isDisabled in
                XCTAssertEqual(isDisabled, false)
                expectation.fulfill()
            }).store(in: cancellable)

        sut.audioState = LocalUserState.AudioState(operation: .pending,
                                                                   device: .receiverSelected)
        sut.micButtonViewModel.update(isDisabled: sut.isMicDisabled())
        let audioState = LocalUserState.AudioState(operation: .off,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)

        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .off)
        XCTAssertEqual(sut.isMicDisabled(), false)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOffAndUpdateWithMicOn_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.micButtonViewModel.$iconName
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
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .on)
        XCTAssertEqual(sut.isMicDisabled(), false)
        XCTAssertEqual(sut.micButtonViewModel.iconName, .micOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOnAndUpdateWithMicOon_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        sut.micButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Mic was .on and update with .on should not publish")
            }).store(in: cancellable)
        sut.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)
        sut.micButtonViewModel.iconName = .micOn
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .on)
        XCTAssertEqual(sut.isMicDisabled(), false)
        XCTAssertEqual(sut.micButtonViewModel.iconName, .micOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_micStatusOnAndUpdateWithMicOff_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.micButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { iconName in
                XCTAssertEqual(iconName, .micOff)
                expectation.fulfill()
            }).store(in: cancellable)
        sut.audioState = LocalUserState.AudioState(operation: .on,
                                                                   device: .receiverSelected)
        sut.micButtonViewModel.iconName = .micOn
        let audioState = LocalUserState.AudioState(operation: .off,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.audioState.operation, .off)
        XCTAssertEqual(sut.isMicDisabled(), false)
        XCTAssertEqual(sut.micButtonViewModel.iconName, .micOff)
        wait(for: [expectation], timeout: 1)
    }

    // MARK: Camera tests
    func test_controlBarViewModel_cameraButtonTapped_when_cameraStatusOff_then_shouldRequestCameraOnTriggered() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .localUserAction(.cameraOnTriggered))
                expectation.fulfill()
            }.store(in: cancellable)
        sut.cameraState = LocalUserState.CameraState(operation: .off,
                                                                     device: .front,
                                                                     transmission: .local)
        sut.cameraButtonTapped()
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_cameraButtonTapped_when_cameraStatusOn_then_shouldRequestCameraOffTriggered() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .localUserAction(.cameraOffTriggered))
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(localUserState: LocalUserState(cameraState: LocalUserState.CameraState(operation: .on,
                                                                                          device: .front,
                                                                                          transmission: .local)),
                   permissionState: PermissionState(),
                   callingState: CallingState())
        sut.cameraButtonTapped()
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_when_selectAudioDeviceButtonTapped_then_audioDeviceSelectionDisplayed() {
        let sut = makeSUT()
        sut.selectAudioDeviceButtonTapped()

        XCTAssertTrue(sut.isAudioDeviceSelectionDisplayed)
    }

    func test_controlBarViewModel_update_when_cameraStatusOffAndUpdateWithCameraOff_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        sut.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Camera was .on and update with .on should not publish")
            }).store(in: cancellable)
        sut.cameraState = LocalUserState.CameraState(operation: .off,
                                                                     device: .front,
                                                                     transmission: .local)
        sut.cameraButtonViewModel.iconName = .videoOff
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.cameraState.operation, .off)
        XCTAssertEqual(sut.cameraButtonViewModel.iconName, .videoOff)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_cameraStatusOffAndUpdateWithCameraOn_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { iconName in
                XCTAssertEqual(iconName, .videoOn)
                expectation.fulfill()
            }).store(in: cancellable)
        sut.cameraState = LocalUserState.CameraState(operation: .off,
                                                                     device: .front,
                                                                     transmission: .local)
        sut.cameraButtonViewModel.iconName = .videoOff

        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.cameraState.operation, .on)
        XCTAssertEqual(sut.cameraButtonViewModel.iconName, .videoOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_cameraStatusOnAndUpdateWithCameraOn_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true
        sut.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Camera was .on and update with .on should not publish")
            }).store(in: cancellable)
        sut.cameraState = LocalUserState.CameraState(operation: .on,
                                                                     device: .front,
                                                                     transmission: .local)
        sut.cameraButtonViewModel.iconName = .videoOn

        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.cameraState.operation, .on)
        XCTAssertEqual(sut.cameraButtonViewModel.iconName, .videoOn)
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_cameraStatusOnAndUpdateWithCameraOff_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        sut.cameraButtonViewModel.$iconName
            .dropFirst(2)
            .sink(receiveValue: { iconName in
                XCTAssertEqual(iconName, .videoOff)
                expectation.fulfill()
            }).store(in: cancellable)
        sut.cameraState = LocalUserState.CameraState(operation: .on,
                                                                     device: .front,
                                                                     transmission: .local)
        sut.cameraButtonViewModel.iconName = .videoOn

        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .receiverSelected)
        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState)
        let permissionState = PermissionState(audioPermission: .granted, cameraPermission: .granted)
        sut.update(localUserState: localUserState,
                   permissionState: permissionState,
                   callingState: CallingState())
        XCTAssertEqual(sut.cameraState.operation, .off)
        XCTAssertEqual(sut.cameraButtonViewModel.iconName, .videoOff)
        wait(for: [expectation], timeout: 1)
    }

    // MARK: Update models tests
    func test_controlBarViewModel_update_when_statesUpdated_then_cameraButtonViewModelIconUpdated() {
        let expectation = XCTestExpectation(description: "Camera button icon should be updated")
        expectation.assertForOverFulfill = true
        factoryMocking.createIconButtonViewModel = { icon in
            guard icon == .videoOff
            else { return nil }

            let iconButtonViewModel = IconButtonViewModelMocking(iconName: .clock)
            iconButtonViewModel.updateIcon = { icon in
                XCTAssertEqual(icon, CompositeIcon.videoOn)
                expectation.fulfill()
            }
            return iconButtonViewModel
        }
        let sut = makeSUT()
        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let localUserState = LocalUserState(cameraState: cameraState)
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_statesUpdated_then_cameraButtonViewModelDisabledStateUpdated() {
        let expectation = XCTestExpectation(description: "Camera button disabled state should be updated")
        expectation.assertForOverFulfill = true
        factoryMocking.createIconButtonViewModel = { icon in
            guard icon == .videoOff
            else { return nil }

            let iconButtonViewModel = IconButtonViewModelMocking(iconName: .clock)
            iconButtonViewModel.updateIsDisabledState = { isDisabled in
                XCTAssertFalse(isDisabled)
                expectation.fulfill()
            }
            return iconButtonViewModel
        }
        let sut = makeSUT()
        let permissionState = PermissionState(cameraPermission: .granted)
        sut.update(localUserState: LocalUserState(),
                   permissionState: permissionState,
                   callingState: CallingState())
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_statesUpdated_then_micButtonViewModelIconUpdated() {
        let expectation = XCTestExpectation(description: "Mic button icon should be updated")
        expectation.assertForOverFulfill = true
        factoryMocking.createIconButtonViewModel = { icon in
            guard icon == .micOff
            else { return nil }

            let iconButtonViewModel = IconButtonViewModelMocking(iconName: .clock)
            iconButtonViewModel.updateIcon = { icon in
                XCTAssertEqual(icon, CompositeIcon.micOn)
                expectation.fulfill()
            }
            return iconButtonViewModel
        }
        let sut = makeSUT()
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .speakerSelected)
        let localUserState = LocalUserState(audioState: audioState)
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_statesUpdated_then_micButtonViewModelDisabledStateUpdated() {
        let expectation = XCTestExpectation(description: "Mic button disabled state should be updated")
        expectation.assertForOverFulfill = true
        factoryMocking.createIconButtonViewModel = { icon in
            guard icon == .micOff
            else { return nil }

            let iconButtonViewModel = IconButtonViewModelMocking(iconName: .clock)
            iconButtonViewModel.updateIsDisabledState = { isDisabled in
                XCTAssertFalse(isDisabled)
                expectation.fulfill()
            }
            return iconButtonViewModel
        }
        let sut = makeSUT()
        let permissionState = PermissionState(audioPermission: .granted)
        sut.update(localUserState: LocalUserState(),
                   permissionState: permissionState,
                   callingState: CallingState())
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_statesUpdated_then_audioDeviceButtonViewModelIconUpdated() {
        let expectation = XCTestExpectation(description: "Mic button disabled state should be updated")
        expectation.assertForOverFulfill = true
        factoryMocking.createIconButtonViewModel = { icon in
            guard icon == .speakerFilled
            else { return nil }

            let iconButtonViewModel = IconButtonViewModelMocking(iconName: .clock)
            iconButtonViewModel.updateIcon = { icon in
                XCTAssertEqual(icon, .speakerBluetooth)
                expectation.fulfill()
            }
            return iconButtonViewModel
        }
        let sut = makeSUT()
        let audioState = LocalUserState.AudioState(operation: .on,
                                                   device: .bluetoothSelected)
        let localUserState = LocalUserState(audioState: audioState)
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_update_when_statesUpdated_then_audioDeviceListViewModelUpdated() {
        let expectation = XCTestExpectation(description: "AudioDevicesListViewModel should be updated")
        let localUserState = LocalUserState(audioState: LocalUserState.AudioState(operation: .on, device: .speakerSelected))
        let audioDevicesListViewModel = AudioDevicesListViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                         dispatchAction: storeFactory.store.dispatch,
                                                                         localUserState: localUserState,
                                                                         localizationProvider: LocalizationProviderMocking())
        audioDevicesListViewModel.updateState = { status in
            XCTAssertEqual(status, localUserState.audioState.device)
            expectation.fulfill()
        }
        factoryMocking.audioDevicesListViewModel = audioDevicesListViewModel
        let sut = makeSUT()
        sut.update(localUserState: localUserState,
                   permissionState: PermissionState(),
                   callingState: CallingState())
        wait(for: [expectation], timeout: 1.0)
    }
}

extension ControlBarViewModelTests {
    func makeSUT(localizationProvider: LocalizationProviderMocking? = nil) -> ControlBarViewModel {
        return ControlBarViewModel(compositeViewModelFactory: factoryMocking,
                                   logger: logger,
                                   localizationProvider: localizationProvider ?? LocalizationProvider(logger: logger),
                                   dispatchAction: storeFactory.store.dispatch,
                                   endCallConfirm: {},
                                   localUserState: storeFactory.store.state.localUserState)
    }

    func makeSUTLocalizationMocking() -> ControlBarViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}

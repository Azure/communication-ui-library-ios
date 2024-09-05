//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class ControlBarViewModelTests: XCTestCase {

    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var localizationProvider: LocalizationProviderMocking!
    var logger: LoggerMocking!
    var factoryMocking: CompositeViewModelFactoryMocking!
    var capabilitiesManager: CapabilitiesManager!

    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store,
                                                          avatarManager: AvatarViewManagerMocking(
                                                            store: storeFactory.store,
                                                            localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                            localParticipantViewData: nil))
        capabilitiesManager = CapabilitiesManager(callType: .groupCall)
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        cancellable = nil
        localizationProvider = nil
        logger = nil
        factoryMocking = nil
        capabilitiesManager = nil
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
        sut.cameraButtonTapped()
        wait(for: [expectation], timeout: 1)
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
        wait(for: [expectation], timeout: 1)
    }

    func test_controlBarViewModel_audioVideoModeAudioOnlyHidesCameraButton() {
        let sut = makeSUT(audioVideoMode: .audioOnly)
        XCTAssertFalse(sut.isCameraDisabled())
    }

    func test_controlBarViewModel_audioVideoModeNormalShowsCameraButton() {
        let sut = makeSUT(audioVideoMode: .audioAndVideo)
        XCTAssertTrue(sut.isAudioDeviceVisible())
    }

    func test_controlBarViewModel_capabilities_turnVideoOn_isCameraDisabledFalse() {
        capabilitiesManager = CapabilitiesManager(callType: .roomsCall)
        let sut = makeSUT(capabilities: [.turnVideoOn])
        XCTAssertFalse(sut.isCameraDisabled())
    }

    func test_controlBarViewModel_capabilities_turnVideoOn_isCameraDisabledTrue() {
        capabilitiesManager = CapabilitiesManager(callType: .roomsCall)
        let sut = makeSUT(capabilities: [])
        XCTAssertTrue(sut.isCameraDisabled())
    }

    func test_controlBarViewModel_capabilities_unmuteMicrophone_isMicDisabledFalse() {
        capabilitiesManager = CapabilitiesManager(callType: .roomsCall)
        let sut = makeSUT(capabilities: [.unmuteMicrophone])
        XCTAssertFalse(sut.isMicDisabled())
    }

    func test_controlBarViewModel_capabilities_unmuteMicrophone_isMicDisabledTrue() {
        capabilitiesManager = CapabilitiesManager(callType: .roomsCall)
        let sut = makeSUT(capabilities: [])
        XCTAssertTrue(sut.isMicDisabled())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
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
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   navigationState: NavigationState())
        wait(for: [expectation], timeout: 1)
    }

    // MARK: Custom OnClick Handler Test

    func test_callCustomOnClickHandler_executesOnClick() {
        let expectation = XCTestExpectation(description: "Custom onClick handler should be executed")
        let button = ButtonViewData { _ in expectation.fulfill() }
        let sut = makeSUT()
        sut.callCustomOnClickHandler(button)
        wait(for: [expectation], timeout: timeout)
    }

    // MARK: More Button Tests

    func test_moreButtonTapped_dispatchesShowMoreOptionsAction() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the showMoreOptions action")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { _ in
                XCTAssertEqual(self.storeFactory.actions.first, .showMoreOptions)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.moreButtonTapped()
        wait(for: [expectation], timeout: timeout)
    }

    func test_isCameraVisible_whenAudioOnlyMode_thenReturnsFalse() {
        let sut = makeSUT(audioVideoMode: .audioOnly)
        XCTAssertFalse(sut.isCameraVisible(.audioOnly))
    }

    func test_isCameraVisible_whenAudioAndVideoMode_thenReturnsTrue() {
        let sut = makeSUT(audioVideoMode: .audioAndVideo)
        XCTAssertTrue(sut.isCameraVisible(.audioAndVideo))
    }

    func test_isMoreButtonVisible_whenCustomButtonsPresent_thenReturnsTrue() {
        let customButton = CustomButtonViewData(id: UUID(), image: UIImage(), title: "Test") { _ in }
        let options = CallScreenControlBarOptions(customButtons: [customButton])
        let sut = makeSUT(controlBarOptions: options)
        XCTAssertTrue(sut.isMoreButtonVisible())
    }

    func test_isMoreButtonVisible_whenNoCustomButtonsAndOtherButtonsInvisible_thenReturnsFalse() {
        let options = CallScreenControlBarOptions(
            liveCaptionsButton: ButtonViewData(visible: false),
            liveCaptionsToggleButton: ButtonViewData(visible: false),
            spokenLanguageButton: ButtonViewData(visible: false),
            captionsLanguageButton: ButtonViewData(visible: false),
            shareDiagnosticsButton: ButtonViewData(visible: false),
            reportIssueButton: ButtonViewData(visible: false),
            customButtons: []
        )
        let sut = makeSUT(controlBarOptions: options)
        XCTAssertFalse(sut.isMoreButtonVisible())
    }
}

extension ControlBarViewModelTests {
    func makeSUT(localizationProvider: LocalizationProviderMocking? = nil,
                 audioVideoMode: CallCompositeAudioVideoMode = .audioAndVideo,
                 capabilities: Set<ParticipantCapabilityType> = [],
                 controlBarOptions: CallScreenControlBarOptions = CallScreenControlBarOptions()) -> ControlBarViewModel {
        var localUserState = LocalUserState(capabilities: capabilities)
        return ControlBarViewModel(compositeViewModelFactory: factoryMocking,
                                   logger: logger,
                                   localizationProvider: localizationProvider ?? LocalizationProvider(logger: logger),
                                   dispatchAction: storeFactory.store.dispatch,
                                   onEndCallTapped: {},
                                   localUserState: localUserState,
                                   audioVideoMode: audioVideoMode,
                                   capabilitiesManager: capabilitiesManager,
                                   controlBarOptions: controlBarOptions)
    }
    func makeSUTWhenDisplayLeaveDiabled(localizationProvider: LocalizationProviderMocking? = nil, audioVideoMode: CallCompositeAudioVideoMode = .audioAndVideo) -> ControlBarViewModel {
        return ControlBarViewModel(compositeViewModelFactory: factoryMocking,
                                   logger: logger,
                                   localizationProvider: localizationProvider ?? LocalizationProvider(logger: logger),
                                   dispatchAction: storeFactory.store.dispatch,
                                   onEndCallTapped: {},
                                   localUserState: storeFactory.store.state.localUserState,
                                   audioVideoMode: audioVideoMode,
                                   capabilitiesManager: capabilitiesManager,
                                   controlBarOptions: nil)
    }

    func makeSUTLocalizationMocking() -> ControlBarViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}

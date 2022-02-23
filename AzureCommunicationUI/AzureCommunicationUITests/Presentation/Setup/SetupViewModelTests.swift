//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class SetupViewModelTests: XCTestCase {

    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var setupViewModel: SetupViewModel!
    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()

        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        setupViewModel = SetupViewModel(compositeViewModelFactory: factoryMocking,
                                        logger: LoggerMocking(),
                                        store: storeFactory.store)
    }

    func test_setupViewModel_when_setupViewLoaded_then_shouldAskAudioPermission() {
        let expectation = XCTestExpectation(description: "Verify Last Action is Request Audio")
        storeFactory.store.$state
            .dropFirst(2)
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is PermissionAction.AudioPermissionRequested)

                expectation.fulfill()
            }.store(in: cancellable)
        storeFactory.store.state = AppState(permissionState: PermissionState(audioPermission: .notAsked))
        setupViewModel.receive(storeFactory.store.state)
        setupViewModel.setupAudioPermissions()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_when_setupViewLoaded_then_shouldSetupCall() {
        let expectation = XCTestExpectation(description: "Verify Last Action is SetupCall")

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is CallingAction.SetupCall)

                expectation.fulfill()
            }.store(in: cancellable)
        setupViewModel.setupCall()

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_when_joinCallButtonTapped_then_shouldCallStartRequest_isJoinRequestedTrue() {
        let expectation = XCTestExpectation(description: "Verify Last Action is Calling View Launched")

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is CallingAction.CallStartRequested)

                expectation.fulfill()
            }.store(in: cancellable)
        setupViewModel.joinCallButtonTapped()
        XCTAssertTrue(setupViewModel.isJoinRequested)
        wait(for: [expectation], timeout: timeout)
    }

    func test_joinCallButtonViewModel_when_audioPermissionDenied_then_shouldDisablejoinCallButton() {
        let permissionState = PermissionState(audioPermission: .denied,
                                              cameraPermission: .notAsked)
        setupViewModel.joinCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)

        XCTAssertTrue(setupViewModel.joinCallButtonViewModel.isDisabled)
    }

    func test_joinCallButtonViewModel_when_audioPermissionGranted_then_shouldEnablejoinCallButton() {
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .denied)
        setupViewModel.joinCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)

        XCTAssertFalse(setupViewModel.joinCallButtonViewModel.isDisabled)

    }

    func test_setupViewModel_when_callingStateUpdateToNone_then_isJoinRequestedFalse() {
        setupViewModel.joinCallButtonTapped()

        let callingState = getCallingState(CallingStatus.connecting)
        let appState = AppState(callingState: callingState)
        setupViewModel.receive(appState)

        let updatedCallingState = getCallingState(CallingStatus.none)
        let updatedAppState = AppState(callingState: updatedCallingState)
        setupViewModel.receive(updatedAppState)

        XCTAssertFalse(setupViewModel.isJoinRequested)
    }

    func test_setupViewModel_when_callingStateUpdateToConnecting_then_isJoinRequestedTrue() {

            setupViewModel.joinCallButtonTapped()

        let updatedCallingState = getCallingState(CallingStatus.connecting)
        let updatedAppState = AppState(callingState: updatedCallingState)
        setupViewModel.receive(updatedAppState)

        XCTAssertTrue(setupViewModel.isJoinRequested)
    }
}

extension SetupViewModelTests {
    func getCallingState(_ statue: CallingStatus = .none) -> CallingState {
        return CallingState(status: statue,
                            isRecordingActive: false,
                            isTranscriptionActive: false)
    }
}

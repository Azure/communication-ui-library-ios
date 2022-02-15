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
        setupViewModel.setupCall()

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is CallingAction.SetupCall)

                expectation.fulfill()
            }.store(in: cancellable)

        wait(for: [expectation], timeout: timeout)
    }

    func test_setupViewModel_when_startCallButtonTapped_then_shouldCallingViewLaunched() {
        let expectation = XCTestExpectation(description: "Verify Last Action is Calling View Launched")
        setupViewModel.startCallButtonTapped()

        storeFactory.store.$state
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.last is CallingViewLaunched)

                expectation.fulfill()
            }.store(in: cancellable)

        wait(for: [expectation], timeout: timeout)
    }

    func test_startCallButtonViewModel_when_audioPermissionDenied_then_shouldDisableStartCallButton() {
        let permissionState = PermissionState(audioPermission: .denied,
                                              cameraPermission: .notAsked)
        setupViewModel.startCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)

        XCTAssertTrue(setupViewModel.startCallButtonViewModel.isDisabled)
    }

    func test_startCallButtonViewModel_when_audioPermissionGranted_then_shouldEnableStartCallButton() {
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .denied)
        setupViewModel.startCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)

        XCTAssertFalse(setupViewModel.startCallButtonViewModel.isDisabled)

    }
}

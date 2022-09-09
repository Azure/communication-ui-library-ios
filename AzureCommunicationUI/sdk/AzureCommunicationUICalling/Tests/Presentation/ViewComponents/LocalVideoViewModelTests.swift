//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class LocalVideoViewModelTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var factoryMocking: CompositeViewModelFactoryMocking!
    var logger: LoggerMocking!

    func test_localVideoViewModel_when_updateWithLocalVideoStreamId_then_videoSteamIdUpdated() {
        let sut = makeSUT()
        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        let localUserState = LocalUserState(cameraState: cameraState,
                                            localVideoStreamIdentifier: "videoSteamId")
        let appState = AppState(permissionState: permissionState,
                                localUserState: localUserState)
        sut.update(localUserState: appState.localUserState)

        let expectedVideoStreamId = "videoSteamId"

        XCTAssertEqual(sut.localVideoStreamId, expectedVideoStreamId)
    }

    // MARK: Camera switch tests
    func test_localVideoVideModel_toggleCameraSwitch_when_cameraStatusOn_then_shouldRequestCameraOnTriggered() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Dispatch the new action")

        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == Action.localUserAction(.cameraSwitchTriggered))
                expectation.fulfill()
            }.store(in: cancellable)

        sut.toggleCameraSwitchTapped()
        wait(for: [expectation], timeout: 1)
    }
}

extension LocalVideoViewModelTests {
    func makeSUT() -> LocalVideoViewModel {
        setupMocking()
        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
        return LocalVideoViewModel(compositeViewModelFactory: factoryMocking,
                                                  logger: logger,
                                                  localizationProvider: LocalizationProviderMocking(),
                                                  dispatchAction: dispatch)
    }

    func setupMocking() {
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
    }
}

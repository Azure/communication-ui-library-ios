//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class LocalVideoViewModelTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var localVideoViewModel: LocalVideoViewModel!

    override func setUp() {
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()

        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        localVideoViewModel = LocalVideoViewModel(compositeViewModelFactory: factoryMocking,
                                                  logger: LoggerMocking(),
                                                  dispatchAction: dispatch)
    }

    func test_localVideoViewModel_when_updateWithLocalVideoStreamId_then_videoSteamIdUpdated() {
        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let permissionState = PermissionState(audioPermission: .granted,
                                              cameraPermission: .granted)
        let localUserState = LocalUserState(cameraState: cameraState,
                                            localVideoStreamIdentifier: "videoSteamId")
        let appState = AppState(permissionState: permissionState,
                                localUserState: localUserState)
        localVideoViewModel.update(localUserState: appState.localUserState)

        let expectedVideoStreamId = "videoSteamId"

        XCTAssertEqual(localVideoViewModel.localVideoStreamId, expectedVideoStreamId)
    }

    // MARK: Camera switch tests
    func test_localVideoVideModel_toggleCameraSwitch_when_cameraStatusOn_then_shouldRequestCameraOnTriggered() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")

        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first is LocalUserAction.CameraSwitchTriggered)
                expectation.fulfill()
            }.store(in: cancellable)

        localVideoViewModel.toggleCameraSwitchTapped()
        wait(for: [expectation], timeout: 1)
    }
}

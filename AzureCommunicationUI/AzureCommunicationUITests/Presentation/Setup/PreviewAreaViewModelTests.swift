//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class PreviewAreaViewModelTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var previewAreaViewModel: PreviewAreaViewModel!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()

        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        previewAreaViewModel = PreviewAreaViewModel(compositeViewModelFactory: factoryMocking,
                                                    dispatchAction: dispatch)
    }

    func test_previewAreaViewModel_when_audioPermissionDenied_then_shouldWarnAudioDisabled() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                 cameraPermission: .notAsked),
                                localUserState: LocalUserState(cameraState: cameraState))
        previewAreaViewModel.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        let expectedIcon = CompositeIcon.micOff
        let expectedText = "Your audio is disabled. To enable, please go to Settings to allow access. You must enable audio to start this call."

        XCTAssertTrue(previewAreaViewModel.showPermissionWarning())
        XCTAssertEqual(previewAreaViewModel.getPermissionWarningIcon(), expectedIcon)
        XCTAssertEqual(previewAreaViewModel.getPermissionWarningText(), expectedText)
    }

    func test_previewAreaViewModel_when_cameraPermissionDenied_then_shouldWarnCameraDisabled() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .denied),
                                localUserState: LocalUserState(cameraState: cameraState))
        previewAreaViewModel.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        let expectedIcon = CompositeIcon.videoOff
        let expectedText = "Your camera is disabled. To enable, please go to Settings to allow access."

        XCTAssertTrue(previewAreaViewModel.showPermissionWarning())
        XCTAssertEqual(previewAreaViewModel.getPermissionWarningIcon(), expectedIcon)
        XCTAssertEqual(previewAreaViewModel.getPermissionWarningText(), expectedText)
    }

    func test_previewAreaViewModel_when_cameraAndAudioPermissionsDenied_then_shouldWarnCameraAudioDisabled() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                 cameraPermission: .denied),
                                localUserState: LocalUserState(cameraState: cameraState))
        previewAreaViewModel.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        let expectedIcon = CompositeIcon.warning
        let expectedText = "Your camera and audio are disabled. To enable, please go to Settings to allow access. You must enable audio to start this call."

        XCTAssertTrue(previewAreaViewModel.showPermissionWarning())
        XCTAssertEqual(previewAreaViewModel.getPermissionWarningIcon(), expectedIcon)
        XCTAssertEqual(previewAreaViewModel.getPermissionWarningText(), expectedText)
    }

    func test_previewAreaViewModel_when_audioPermissionsGranted_cameraOff_then_shouldHideWarning_showAvatar() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .notAsked),
                                localUserState: LocalUserState(cameraState: cameraState))
        previewAreaViewModel.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(previewAreaViewModel.showPermissionWarning())
    }

    func test_previewAreaViewModel_when_cameraAndAudioPermissionsGranted_then_shouldHideWarning() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .granted),
                                localUserState: LocalUserState(cameraState: cameraState))
        previewAreaViewModel.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(previewAreaViewModel.showPermissionWarning())
    }

    func test_previewAreaViewModel_when_permissionWarningHidden_cameraOff_then_showAvatar() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .granted),
                                localUserState: LocalUserState(cameraState: cameraState))
        previewAreaViewModel.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(previewAreaViewModel.showPermissionWarning())
    }

    func test_previewAreaViewModel_when_permissionWarningHidden_cameraOn_then_showVideoRender() {
        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .granted),
                                localUserState: LocalUserState(cameraState: cameraState))
        previewAreaViewModel.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(previewAreaViewModel.showPermissionWarning())
    }
}

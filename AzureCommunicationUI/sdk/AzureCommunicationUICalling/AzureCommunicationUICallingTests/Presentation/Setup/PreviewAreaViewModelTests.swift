//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class PreviewAreaViewModelTests: XCTestCase {
    private var storeFactory: StoreFactoryMocking!
    private var factoryMocking: CompositeViewModelFactoryMocking!
    private var logger: LoggerMocking!
    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        logger = LoggerMocking()
        localizationProvider = LocalizationProviderMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger,
                                                          store: storeFactory.store)
    }

    func test_previewAreaViewModel_when_audioPermissionDenied_then_shouldWarnAudioDisabled() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                 cameraPermission: .notAsked),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUT()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        let expectedIcon = CompositeIcon.micOff
        let expectedText = "Your audio is disabled. To enable, please go to Settings to allow access. You must enable audio to start this call."

        XCTAssertTrue(sut.isPermissionsDenied)
        XCTAssertEqual(sut.getPermissionWarningIcon(), expectedIcon)
        XCTAssertEqual(sut.getPermissionWarningText(), expectedText)
    }

    func test_previewAreaViewModel_when_cameraPermissionDenied_then_shouldWarnCameraDisabled() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .denied),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUT()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        let expectedIcon = CompositeIcon.videoOff
        let expectedText = "Your camera is disabled. To enable, please go to Settings to allow access."

        XCTAssertTrue(sut.isPermissionsDenied)
        XCTAssertEqual(sut.getPermissionWarningIcon(), expectedIcon)
        XCTAssertEqual(sut.getPermissionWarningText(), expectedText)
    }

    func test_previewAreaViewModel_when_cameraAndAudioPermissionsDenied_then_shouldWarnCameraAudioDisabled() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                 cameraPermission: .denied),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUT()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        let expectedIcon = CompositeIcon.warning
        let expectedText = "Your camera and audio are disabled. To enable, please go to Settings to allow access. You must enable audio to start this call."

        XCTAssertTrue(sut.isPermissionsDenied)
        XCTAssertEqual(sut.getPermissionWarningIcon(), expectedIcon)
        XCTAssertEqual(sut.getPermissionWarningText(), expectedText)
    }

    func test_previewAreaViewModel_when_audioPermissionsGranted_cameraOff_then_shouldHideWarning_showAvatar() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .notAsked),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUT()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(sut.isPermissionsDenied)
    }

    func test_previewAreaViewModel_when_cameraAndAudioPermissionsGranted_then_shouldHideWarning() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .granted),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUT()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(sut.isPermissionsDenied)
    }

    func test_previewAreaViewModel_when_permissionWarningHidden_cameraOff_then_showAvatar() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .granted),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUT()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(sut.isPermissionsDenied)
    }

    func test_previewAreaViewModel_when_permissionWarningHidden_cameraOn_then_showVideoRender() {
        let cameraState = LocalUserState.CameraState(operation: .on,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .granted,
                                                                 cameraPermission: .granted),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUT()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        XCTAssertFalse(sut.isPermissionsDenied)
    }

    func test_previewAreaViewModel_update_when_statesUpdated_then_localVideoViewModelUpdated() {
        let expectation = XCTestExpectation(description: "LocalVideoViewModel is updated")
        let localUserState = LocalUserState(displayName: "UpdatedDisplayName")
        factoryMocking.localVideoViewModel = LocalVideoViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                                        logger: logger,
                                                                        localizationProvider: localizationProvider,
                                                                        dispatchAction: storeFactory.store.dispatch,
                                                                        updateState: { localState in
            XCTAssertEqual(localUserState.displayName, localState.displayName)
            expectation.fulfill()
        })
        let sut = makeSUT()
        sut.update(localUserState: localUserState, permissionState: PermissionState())
        wait(for: [expectation], timeout: 1.0)
    }

    func test_previewAreaViewModel_displays_previewAreaText_from_LocalizationMocking() {
        let cameraState = LocalUserState.CameraState(operation: .off,
                                                     device: .front,
                                                     transmission: .local)
        let appState = AppState(permissionState: PermissionState(audioPermission: .denied,
                                                                 cameraPermission: .notAsked),
                                localUserState: LocalUserState(cameraState: cameraState))
        let sut = makeSUTLocalizationMocking()
        sut.update(localUserState: appState.localUserState, permissionState: appState.permissionState)

        let expectedIcon = CompositeIcon.micOff
        let expectedTextKey = "AzureCommunicationUICalling.SetupView.PreviewArea.AudioDisabled"

        XCTAssertTrue(sut.isPermissionsDenied)
        XCTAssertEqual(sut.getPermissionWarningIcon(), expectedIcon)
        XCTAssertEqual(sut.getPermissionWarningText(), expectedTextKey)
    }

}

extension PreviewAreaViewModelTests {
    func makeSUT() -> PreviewAreaViewModel {
        return PreviewAreaViewModel(compositeViewModelFactory: factoryMocking,
                                    dispatchAction: storeFactory.store.dispatch,
                                    localizationProvider: LocalizationProvider(logger: logger))
    }

    func makeSUTLocalizationMocking() -> PreviewAreaViewModel {
        return PreviewAreaViewModel(compositeViewModelFactory: factoryMocking,
                                    dispatchAction: storeFactory.store.dispatch,
                                    localizationProvider: localizationProvider)
    }
}

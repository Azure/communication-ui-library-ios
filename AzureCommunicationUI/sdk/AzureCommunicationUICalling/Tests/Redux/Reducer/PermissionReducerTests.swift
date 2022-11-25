//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class PermissionReducerTests: XCTestCase {

    func test_permissionReducer_reduce_when_audioPermissionSet_shouldReturnAudioPermissionGranted() {
        let state = PermissionState()
        let action = PermissionAction.audioPermissionGranted
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioPermission, .granted)
    }

    func test_permissionReducer_reduce_when_audioPermissionRequest_shouldReturnAudioPermissionRequesting() {
        let state = PermissionState()
        let action = PermissionAction.audioPermissionRequested
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioPermission, .requesting)
    }

    func test_permissionReducer_reduce_when_audioPermissionNotAsked_shouldReturnAudioPermissionNotAsked() {
        let state = PermissionState()
        let action = PermissionAction.audioPermissionNotAsked
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioPermission, .notAsked)
    }

    func test_permissionReducer_reduce_when_cameraPermissionSet_shouldReturnCameraPermissionGranted() {
        let state = PermissionState()
        let action = PermissionAction.cameraPermissionGranted
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraPermission, .granted)
    }

    func test_permissionReducer_reduce_when_cameraPermissionRequest_shouldReturnCameraPermissionRequesting() {
        let state = PermissionState()
        let action = PermissionAction.cameraPermissionRequested
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraPermission, .requesting)
    }

    func test_permissionReducer_reduce_when_cameraPermissionNotAsked_shouldReturnCameraPermissionNotAsked() {
        let state = PermissionState()
        let action = PermissionAction.cameraPermissionNotAsked

        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraPermission, .notAsked)
    }
}

extension PermissionReducerTests {
    private func makeSUT() -> Reducer<PermissionState, PermissionAction> {
        return .livePermissionsReducer
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class PermissionReducerTests: XCTestCase {

    func test_permissionReducer_reduce_when_audioPermissionSet_shouldReturnAudioPermissionGranted() {
        let state = PermissionState()
        let action = PermissionAction.audioPermissionGranted
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioPermission, .granted)
    }

    func test_permissionReducer_reduce_when_audioPermissionRequest_shouldReturnAudioPermissionRequesting() {
        let state = PermissionState()
        let action = PermissionAction.audioPermissionRequested
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioPermission, .requesting)
    }

    func test_permissionReducer_reduce_when_audioPermissionNotAsked_shouldReturnAudioPermissionNotAsked() {
        let state = PermissionState()
        let action = PermissionAction.audioPermissionNotAsked
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioPermission, .notAsked)
    }

    func test_permissionReducer_reduce_when_cameraPermissionSet_shouldReturnCameraPermissionGranted() {
        let state = PermissionState()
        let action = PermissionAction.cameraPermissionGranted
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraPermission, .granted)
    }

    func test_permissionReducer_reduce_when_cameraPermissionRequest_shouldReturnCameraPermissionRequesting() {
        let state = PermissionState()
        let action = PermissionAction.cameraPermissionRequested
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraPermission, .requesting)
    }

    func test_permissionReducer_reduce_when_cameraPermissionNotAsked_shouldReturnCameraPermissionNotAsked() {
        let state = PermissionState()
        let action = PermissionAction.cameraPermissionNotAsked

        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraPermission, .notAsked)
    }
}

extension PermissionReducerTests {
    private func getSUT() -> Reducer<PermissionState, PermissionAction> {
        return livePermissionsReducer
    }
}

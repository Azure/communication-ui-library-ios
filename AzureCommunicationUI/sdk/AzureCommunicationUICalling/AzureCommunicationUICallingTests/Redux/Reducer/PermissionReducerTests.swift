//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class PermissionReducerTests: XCTestCase {

    func test_permissionReducer_reduce_when_notPermissionState_then_return() {
        let state = StateMocking()
        let action = PermissionAction.AudioPermissionGranted()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssert(resultState is StateMocking)
    }

    func test_permissionReducer_reduce_when_audioPermissionSet_shouldReturnAudioPermissionGranted() {
        let state = PermissionState()
        let action = PermissionAction.AudioPermissionGranted()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? PermissionState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioPermission, .granted)
    }

    func test_permissionReducer_reduce_when_audioPermissionRequest_shouldReturnAudioPermissionRequesting() {
        let state = PermissionState()
        let action = PermissionAction.AudioPermissionRequested()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? PermissionState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioPermission, .requesting)
    }

    func test_permissionReducer_reduce_when_audioPermissionNotAsked_shouldReturnAudioPermissionNotAsked() {
        let state = PermissionState()
        let action = PermissionAction.AudioPermissionNotAsked()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? PermissionState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioPermission, .notAsked)
    }

    func test_permissionReducer_reduce_when_cameraPermissionSet_shouldReturnCameraPermissionGranted() {
        let state = PermissionState()
        let action = PermissionAction.CameraPermissionGranted()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? PermissionState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraPermission, .granted)
    }

    func test_permissionReducer_reduce_when_cameraPermissionRequest_shouldReturnCameraPermissionRequesting() {
        let state = PermissionState()
        let action = PermissionAction.CameraPermissionRequested()

        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? PermissionState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraPermission, .requesting)
    }

    func test_permissionReducer_reduce_when_cameraPermissionNotAsked_shouldReturnCameraPermissionNotAsked() {
        let state = PermissionState()
        let action = PermissionAction.CameraPermissionNotAsked()

        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? PermissionState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraPermission, .notAsked)
    }

    func test_permissionReducer_reduce_when_mockingAction_then_stateNotUpdate() {
        let expectedState = AppPermission.Status.granted
        let state = PermissionState(audioPermission: expectedState,
                                    cameraPermission: expectedState)
        let action = ActionMocking()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? PermissionState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState.cameraPermission, expectedState)
        XCTAssertEqual(resultState.audioPermission, expectedState)
    }
}

extension PermissionReducerTests {
    private func getSUT() -> PermissionReducer {
        return PermissionReducer()
    }

}

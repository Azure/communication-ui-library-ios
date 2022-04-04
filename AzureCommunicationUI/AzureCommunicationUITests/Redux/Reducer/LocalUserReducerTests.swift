//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class LocalUserReducerTests: XCTestCase {
    func test_localUserReducer_reduce_when_notLocalUserState_then_return() {
        let state = StateMocking()
        let action = LocalUserAction.MicrophoneOffTriggered()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssert(resultState is StateMocking)
    }

    func test_localUserReducer_reduce_when_localUserActionUpdateMicStateUpdated_then_localUserMuted() {
        let state = LocalUserState()
        let action = LocalUserAction.MicrophoneMuteStateUpdated(isMuted: true)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.operation, .off)
    }

    func test_localUserReducer_reduce_when_localUserActionUpdateMicStateUpdated_then_localUserUnMuted() {
        let state = LocalUserState()
        let action = LocalUserAction.MicrophoneMuteStateUpdated(isMuted: false)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.operation, .on)
    }

    func test_localUserReducer_reduce_when_localUserActionUpdateCameraStatusOn_then_micStatusIsOn() {
        let state = LocalUserState()
        let expectedVideoId = "expected"
        let action = LocalUserAction.CameraOnSucceeded(videoStreamIdentifier: expectedVideoId)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.operation, .on)
        XCTAssertEqual(resultState.localVideoStreamIdentifier, expectedVideoId)
    }

    func test_localUserReducer_reduce_when_localUserActionUpdateCameraStatusOff_then_micStatusIsOff() {
        let state = LocalUserState()
        let action = LocalUserAction.CameraOffSucceeded()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.operation, .off)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophoneOnRequested_then_micStatusSwitching() {
        let state = LocalUserState()
        let action = LocalUserAction.MicrophoneOnTriggered()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.operation, .pending)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophoneOffRequested_then_micStatusSwitching() {
        let state = LocalUserState()
        let action = LocalUserAction.MicrophoneOffTriggered()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.operation, .pending)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophonePreviewOn_then_micStatusOn() {
        let state = LocalUserState()
        let action = LocalUserAction.MicrophonePreviewOn()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.operation, .on)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophonePreviewOff_then_micStatusOff() {
        let state = LocalUserState()
        let action = LocalUserAction.MicrophonePreviewOff()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.operation, .off)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraSwitchTriggered_then_cameraDeviceStatusIsSwitching() {
        let state = LocalUserState()
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.switching
        let action = LocalUserAction.CameraSwitchTriggered()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.device, expectedCameraDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraSwitchSuccessToBack_then_cameraDeviceStatusIsBack() {
        let state = LocalUserState()
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.back
        let action = LocalUserAction.CameraSwitchSucceeded(cameraDevice: .back)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.device, expectedCameraDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraSwitchFail_then_cameraDeviceStatusIsError() {
        let state = LocalUserState()
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.error(ErrorMocking.mockError)
        let action = LocalUserAction.CameraSwitchFailed(error: ErrorMocking.mockError)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.device, expectedCameraDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeRequested_then_audioDeviceStatusIsSpeakerRequested() {
        let state = LocalUserState()
        let action = LocalUserAction.AudioDeviceChangeRequested(device: .speaker)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.device, .speakerRequested)
    }

    func test_localUserReducer_reduce_when_localUserAudioDeviceChangeRequested_then_audioDeviceStatusIsReceiverRequested() {
        let state = LocalUserState()
        let action = LocalUserAction.AudioDeviceChangeRequested(device: .receiver)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.device, .receiverRequested)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeSucceeded_then_audioDeviceStatusIsSpeakerSelected() {
        let state = LocalUserState()
        let action = LocalUserAction.AudioDeviceChangeSucceeded(device: .speaker)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.device, .speakerSelected)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeSucceeded_then_audioDeviceStatusIsReceiverSelected() {
        let state = LocalUserState()
        let action = LocalUserAction.AudioDeviceChangeSucceeded(device: .receiver)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.device, .receiverSelected)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeFailed_then_audioDeviceStatusIsError() {
        let state = LocalUserState()
        let expectedAudioDeviceStatus = LocalUserState.AudioDeviceSelectionStatus.error(ErrorMocking.mockError)
        let action = LocalUserAction.AudioDeviceChangeFailed(error: ErrorMocking.mockError)
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.audioState.device, expectedAudioDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraPreviewOnTriggered_then_cameraTransmissionStatusIsLocal_cameraStatusIsPending() {
        let state = LocalUserState()
        let expectedCameraTransmissionStatus = LocalUserState.CameraTransmissionStatus.local
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.pending
        let action = LocalUserAction.CameraPreviewOnTriggered()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.transmission, expectedCameraTransmissionStatus)
        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)

    }

    func test_localUserReducer_reduce_when_localUserActionCameraOnTriggered_then_cameraTransmissionStatusIsRemote_cameraStatusIsPending() {
        let state = LocalUserState()
        let expectedCameraTransmissionStatus = LocalUserState.CameraTransmissionStatus.remote
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.pending
        let action = LocalUserAction.CameraOnTriggered()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.transmission, expectedCameraTransmissionStatus)
        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraOffTriggered_then_cameraStatusIsPending() {
        let state = LocalUserState()
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.pending
        let action = LocalUserAction.CameraOffTriggered()
        let sut = getSUT()
        guard let resultState = sut.reduce(state, action) as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)
    }

    func test_localUserReducer_reduce_when_mockingAction_then_stateNotUpdate() {
        let expectedVideoId = "expected"

        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.off
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.front
        let expectedMicStatus = LocalUserState.AudioOperationalStatus.off
        let expectedCameraState = LocalUserState.CameraState(operation: expectedCameraStatus,
                                                             device: expectedCameraDeviceStatus,
                                                             transmission: .local)
        let expectedAudioState = LocalUserState.AudioState(operation: expectedMicStatus,
                                                           device: .receiverSelected)
        let state = LocalUserState(cameraState: expectedCameraState,
                                   audioState: expectedAudioState,
                                   displayName: "",
                                   localVideoStreamIdentifier: expectedVideoId)
        let action = ActionMocking()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? LocalUserState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)
        XCTAssertEqual(resultState.cameraState.device, expectedCameraDeviceStatus)
        XCTAssertEqual(resultState.audioState.operation, expectedMicStatus)
        XCTAssertEqual(resultState.localVideoStreamIdentifier, expectedVideoId)
    }
}

extension LocalUserReducerTests {
    func getSUT() -> LocalUserReducer {
        return LocalUserReducer()
    }
}

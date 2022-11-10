//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class LocalUserReducerTests: XCTestCase {

    func test_localUserReducer_reduce_when_localUserActionUpdateMicStateUpdated_then_localUserMuted() {
        let state = LocalUserState()
        let action = LocalUserAction.microphoneMuteStateUpdated(isMuted: true)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.operation, .off)
    }

    func test_localUserReducer_reduce_when_localUserActionUpdateMicStateUpdated_then_localUserUnMuted() {
        let state = LocalUserState()
        let action = LocalUserAction.microphoneMuteStateUpdated(isMuted: false)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.operation, .on)
    }

    func test_localUserReducer_reduce_when_localUserActionUpdateCameraStatusOn_then_micStatusIsOn() {
        let state = LocalUserState()
        let expectedVideoId = "expected"
        let action = LocalUserAction.cameraOnSucceeded(videoStreamIdentifier: expectedVideoId)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.operation, .on)
        XCTAssertEqual(resultState.localVideoStreamIdentifier, expectedVideoId)
    }

    func test_localUserReducer_reduce_when_localUserActionUpdateCameraStatusOff_then_micStatusIsOff() {
        let state = LocalUserState()
        let action = LocalUserAction.cameraOffSucceeded
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.operation, .off)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophoneOnRequested_then_micStatusSwitching() {
        let state = LocalUserState()
        let action = LocalUserAction.microphoneOnTriggered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.operation, .pending)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophoneOffRequested_then_micStatusSwitching() {
        let state = LocalUserState()
        let action = LocalUserAction.microphoneOffTriggered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.operation, .pending)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophonePreviewOn_then_micStatusOn() {
        let state = LocalUserState()
        let action = LocalUserAction.microphonePreviewOn
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.operation, .on)
    }

    func test_localUserReducer_reduce_when_localUserActionMicrophonePreviewOff_then_micStatusOff() {
        let state = LocalUserState()
        let action = LocalUserAction.microphonePreviewOff
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.operation, .off)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraSwitchTriggered_then_cameraDeviceStatusIsSwitching() {
        let state = LocalUserState()
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.switching
        let action = LocalUserAction.cameraSwitchTriggered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.device, expectedCameraDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraSwitchSuccessToBack_then_cameraDeviceStatusIsBack() {
        let state = LocalUserState()
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.back
        let action = LocalUserAction.cameraSwitchSucceeded(cameraDevice: .back)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.device, expectedCameraDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraSwitchFail_then_cameraDeviceStatusIsError() {
        let state = LocalUserState()
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.error(ErrorMocking.mockError)
        let action = LocalUserAction.cameraSwitchFailed(error: ErrorMocking.mockError)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.device, expectedCameraDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeRequested_then_audioDeviceStatusIsSpeakerRequested() {
        let state = LocalUserState()
        let action = LocalUserAction.audioDeviceChangeRequested(device: .speaker)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.device, .speakerRequested)
    }

    func test_localUserReducer_reduce_when_localUserAudioDeviceChangeRequested_then_audioDeviceStatusIsReceiverRequested() {
        let state = LocalUserState()
        let action = LocalUserAction.audioDeviceChangeRequested(device: .receiver)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.device, .receiverRequested)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeSucceeded_then_audioDeviceStatusIsSpeakerSelected() {
        let state = LocalUserState()
        let action = LocalUserAction.audioDeviceChangeSucceeded(device: .speaker)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.device, .speakerSelected)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeSucceeded_then_audioDeviceStatusIsReceiverSelected() {
        let state = LocalUserState()
        let action = LocalUserAction.audioDeviceChangeSucceeded(device: .receiver)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.device, .receiverSelected)
    }

    func test_localUserReducer_reduce_when_localUserActionAudioDeviceChangeFailed_then_audioDeviceStatusIsError() {
        let state = LocalUserState()
        let expectedAudioDeviceStatus = LocalUserState.AudioDeviceSelectionStatus.error(ErrorMocking.mockError)
        let action = LocalUserAction.audioDeviceChangeFailed(error: ErrorMocking.mockError)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioState.device, expectedAudioDeviceStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraPreviewOnTriggered_then_cameraTransmissionStatusIsLocal_cameraStatusIsPending() {
        let state = LocalUserState()
        let expectedCameraTransmissionStatus = LocalUserState.CameraTransmissionStatus.local
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.pending
        let action = LocalUserAction.cameraPreviewOnTriggered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.transmission, expectedCameraTransmissionStatus)
        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)

    }

    func test_localUserReducer_reduce_when_localUserActionCameraOnTriggered_then_cameraTransmissionStatusIsRemote_cameraStatusIsPending() {
        let state = LocalUserState()
        let expectedCameraTransmissionStatus = LocalUserState.CameraTransmissionStatus.remote
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.pending
        let action = LocalUserAction.cameraOnTriggered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.transmission, expectedCameraTransmissionStatus)
        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraOffTriggered_then_cameraStatusIsPending() {
        let state = LocalUserState()
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.pending
        let action = LocalUserAction.cameraOffTriggered
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)
    }

    func test_localUserReducer_reduce_when_localUserActionCameraPausedSucceeded_then_cameraStatusIsPaused() {
        let state = LocalUserState()
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.paused
        let action = LocalUserAction.cameraPausedSucceeded
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.cameraState.operation, expectedCameraStatus)
    }
}

extension LocalUserReducerTests {
    func makeSUT() -> Reducer<LocalUserState, LocalUserAction> {
        return .liveLocalUserReducer
    }
}

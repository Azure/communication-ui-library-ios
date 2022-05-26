//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
@testable import AzureCommunicationUICalling

class CallingMiddlewareHandlerTests: XCTestCase {

    var callingMiddlewareHandler: CallingMiddlewareHandler!
    var mockLogger: LoggerMocking!
    var mockCallingService: CallingServiceMocking!

    override func setUp() {
        super.setUp()
        mockCallingService = CallingServiceMocking()
        mockLogger = LoggerMocking()
        callingMiddlewareHandler = CallingMiddlewareHandler(callingService: mockCallingService, logger: mockLogger)
    }

    func test_callingMiddlewareHandler_requestMicMute_then_muteLocalMicCalled() {
        callingMiddlewareHandler.requestMicrophoneMute(state: getEmptyState(), dispatch: getEmptyDispatch())

        XCTAssertTrue(mockCallingService.muteLocalMicCalled)
    }

    func test_callingMiddlewareHandler_requestMicUnmute_then_unmuteLocalMicCalled() {
        callingMiddlewareHandler.requestMicrophoneUnmute(state: getEmptyState(), dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.unmuteLocalMicCalled)
    }

    func test_callingMiddlewareHandler_requestMicMute_when_returnsError_then_updateMicrophoneStatusIsError() {
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.MicrophoneOffFailed)
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestMicrophoneMute(state: getEmptyState(), dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_requestMicUnmute_when_returnsError_then_updateMicrophoneStatusIsError() {
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.MicrophoneOnFailed)
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestMicrophoneUnmute(state: getEmptyState(), dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_requestCameraOn_when_cameraPermissionNotAsked_then_shouldDispatchCameraPermissionRequested() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        func dispatch(action: Action) {
            XCTAssertTrue(action is PermissionAction.CameraPermissionRequested)
            expectation.fulfill()
        }
        guard let state: AppState = getState(callingState: .connected,
                                       cameraStatus: .off,
                                       cameraDeviceStatus: .front,
                                             cameraPermission: .notAsked) as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        callingMiddlewareHandler.requestCameraOn(state: state, dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_requestCameraOff_then_stopLocalVideoStreamCalled() {
        callingMiddlewareHandler.requestCameraOff(state: getEmptyState(), dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_requestCameraOff_when_permissionNotAsked_then_updateCameraStatusOffUpdate() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOffSucceeded)
            expectation.fulfill()
        }
        callingMiddlewareHandler.requestCameraOff(state: getEmptyState(), dispatch: dispatch)

        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_requestCameraOn_then_startLocalVideoStreamCalled() {
        callingMiddlewareHandler.requestCameraOn(state: getEmptyState(), dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_requestCameraOn_when_noError_then_updateCameraStatusOnUpdate() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")

        let videoId = "Identifier"
        mockCallingService.videoStreamId = videoId
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOnSucceeded)
            switch action {
            case let action as LocalUserAction.CameraOnSucceeded:
                XCTAssertEqual(action.videoStreamIdentifier, videoId)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        callingMiddlewareHandler.requestCameraOn(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_requestCameraOff_when_returnsError_then_updateCameraStatusIsError() {
        let expectation = XCTestExpectation(description: "Request Camera Off Dispatch Action Should Return Error")
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOffFailed)
            expectation.fulfill()
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestCameraOff(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_requestCameraOn_when_returnsError_then_updateCameraStatusIsError() {
        let expectation = XCTestExpectation(description: "Request Camera On Dispatch Action Should Return Error")
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOnFailed)
            expectation.fulfill()
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestCameraOn(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_requestCameraSwitch_then_switchCameraCalled() {
        callingMiddlewareHandler.requestCameraSwitch(state: getEmptyState(), dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.switchCameraCalled)
    }

    func test_callingMiddlewareHandler_requestCameraSwitch_when_noError_then_updateCameraDeviceStatusOnUpdate() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")

        let cameraDevice = CameraDevice.front
        mockCallingService.cameraDevice = cameraDevice
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraSwitchSucceeded)
            switch action {
            case let action as LocalUserAction.CameraSwitchSucceeded:
                XCTAssertEqual(action.cameraDevice, cameraDevice)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        callingMiddlewareHandler.requestCameraSwitch(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_requestCameraSwitch_when_returnsError_then_updateCameraDeviceStatusIsError() {
        let expectation = XCTestExpectation(description: "Request Camera Switch Dispatch Action Should Return Error")
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraSwitchFailed)
            expectation.fulfill()
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestCameraSwitch(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_endCall_then_endCallCalled() {
        callingMiddlewareHandler.endCall(state: getEmptyState(), dispatch: getEmptyDispatch())

        XCTAssertTrue(mockCallingService.endCallCalled)
    }

    func test_callingMiddlewareHandler_startCall_then_startCallCalled() {
        callingMiddlewareHandler.startCall(state: getEmptyState(), dispatch: getEmptyDispatch())

        XCTAssertTrue(mockCallingService.startCallCalled)
    }

    func test_callingMiddlewareHandler_endCall_when_returnNSError_then_updateCallError() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")

        let error = getError()
        let expectedStatus = CallErrorEvent(code: CallErrorCode.callEnd, error: error)

        func dispatch(action: Action) {
            XCTAssertTrue(action is ErrorAction.FatalErrorUpdated)
            switch action {
            case let action as ErrorAction.FatalErrorUpdated:
                XCTAssertEqual(action.error.code, expectedStatus.code)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        callingMiddlewareHandler.endCall(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_endCall_when_returnsCompositeError_then_updateClientError() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")

        let error = CompositeError.invalidSDKWrapper
        let expectedError = CallErrorEvent(code: CallErrorCode.callEnd, error: error)
        func dispatch(action: Action) {
            XCTAssertTrue(action is ErrorAction.FatalErrorUpdated)
            switch action {
            case let action as ErrorAction.FatalErrorUpdated:
                XCTAssertEqual(action.error.code, expectedError.code)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        callingMiddlewareHandler.endCall(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_startCall_when_returnsNSError_then_updateCallingCoreError() {
        let error = getError()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedStatus = CallErrorEvent(code: CallErrorCode.callJoin, error: error)
        func dispatch(action: Action) {
            XCTAssertTrue(action is ErrorAction.FatalErrorUpdated)
            switch action {
            case let action as ErrorAction.FatalErrorUpdated:
                XCTAssertEqual(action.error.code, expectedStatus.code)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        callingMiddlewareHandler.startCall(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_startCall_when_returnsCompositeError_then_updateClientError() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let error = CompositeError.invalidSDKWrapper
        let expectedError = CallErrorEvent(code: CallErrorCode.callJoin, error: error)

        func dispatch(action: Action) {
            XCTAssertTrue(action is ErrorAction.FatalErrorUpdated)
            switch action {
            case let action as ErrorAction.FatalErrorUpdated:
                XCTAssertEqual(action.error.code, expectedError.code)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        callingMiddlewareHandler.startCall(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_setupCall_then_setupCallCalled() {
        callingMiddlewareHandler.setupCall(state: getEmptyState(), dispatch: getEmptyDispatch())

        XCTAssertTrue(mockCallingService.setupCallCalled)
    }

    func test_callingMiddlewareHandler_setupCall_when_cameraPermissionGranted_then_cameraOnTriggered() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")

        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraPreviewOnTriggered)
            expectation.fulfill()
        }
        callingMiddlewareHandler.setupCall(state: getState(callingState: .connected,
                                                           cameraStatus: .off,
                                                           cameraDeviceStatus: .front,
                                                           cameraPermission: .granted),
                                           dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_setupCall_when_cameraPermissionDenied_then_skipCameraOnTriggered() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true

        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOnTriggered)
            expectation.fulfill()
        }
        callingMiddlewareHandler.setupCall(state: getState(callingState: .connected,
                                                           cameraStatus: .off,
                                                           cameraDeviceStatus: .front,
                                                           cameraPermission: .denied),
                                           dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_setupCall_when_returnsError_then_updateCallingCoreError() {
        let error = getError()
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let expectedStatus = CallErrorEvent(code: CallErrorCode.callJoin, error: error)
        func dispatch(action: Action) {
            XCTAssertTrue(action is ErrorAction.FatalErrorUpdated)
            switch action {
            case let action as ErrorAction.FatalErrorUpdated:
                XCTAssertEqual(action.error.code, expectedStatus.code)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        callingMiddlewareHandler.setupCall(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_then_stopLocalVideoStreamCalled() {
        callingMiddlewareHandler.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterBackground_when_callNotConnected_then_stopLocalVideoStreamNotCalled() {
        callingMiddlewareHandler.enterBackground(state: getState(callingState: .disconnected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: getEmptyDispatch())
        XCTAssertFalse(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterBackground_when_cameraStatusNotOn_then_stopLocalVideoStreamNotCalled() {
        callingMiddlewareHandler.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .off,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: getEmptyDispatch())
        XCTAssertFalse(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_noError_then_updateCameraStatusPauseUpdate() {
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraPausedSucceeded)
        }
        callingMiddlewareHandler.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_returnsError_then_updateCameraStatusIsError() {
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraPausedFailed)
        }
        mockCallingService.error = error
        callingMiddlewareHandler.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callConnected_cameraStatusPaused_then_startLocalVideoStreamCalled() {
        callingMiddlewareHandler.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callNotStarted_then_startLocalVideoStreamNotCalled() {
        callingMiddlewareHandler.enterForeground(state: getState(callingState: .disconnected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: getEmptyDispatch())
        XCTAssertFalse(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_cameraStatusNotPaused_then_startLocalVideoStreamNotCalled() {
        callingMiddlewareHandler.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .off,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: getEmptyDispatch())
        XCTAssertFalse(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callConnected_cameraStatusOn_noError_then_updateCameraStatusOnUpdate() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let id = "identifier"
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOnSucceeded)
            switch action {
            case let action as LocalUserAction.CameraOnSucceeded:
                XCTAssertEqual(action.videoStreamIdentifier, id)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.videoStreamId = id
        callingMiddlewareHandler.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callConnected_cameraStatusOn_returnsError_then_updateCameraStatusIsError() {
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOnFailed)
        }
        mockCallingService.error = error
        callingMiddlewareHandler.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionLocal_cameraPermissionRequesting_then_updateCameraPreviewOnTriggered() {
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraPreviewOnTriggered)
        }
        callingMiddlewareHandler.onCameraPermissionIsSet(state: getState(cameraPermission: .requesting,
                                                                         cameraTransmissionStatus: .local),
                                                 dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionRemote_cameraPermissionRequesting_then_updateCameraOnTriggered() {
        func dispatch(action: Action) {
            XCTAssertTrue(action is LocalUserAction.CameraOnTriggered)
        }
        callingMiddlewareHandler.onCameraPermissionIsSet(state: getState(cameraPermission: .requesting,
                                                                         cameraTransmissionStatus: .remote),
                                                 dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionRemote_cameraPermissionNotRequesting_then_updateCameraOnTriggered() {
        func dispatch(action: Action) {
            XCTFail("Failed with unknown action dispatched")
        }
        callingMiddlewareHandler.onCameraPermissionIsSet(state: getState(cameraPermission: .granted,
                                                                         cameraTransmissionStatus: .remote),
                                                 dispatch: dispatch)
    }
}

extension CallingMiddlewareHandlerTests {

    private func getEmptyState() -> ReduxState? {
        return AppState()
    }

    private func getState(callingState: CallingStatus = .none,
                          cameraStatus: LocalUserState.CameraOperationalStatus = .on,
                          cameraDeviceStatus: LocalUserState.CameraDeviceSelectionStatus = .front,
                          cameraPermission: AppPermission.Status = .unknown,
                          cameraTransmissionStatus: LocalUserState.CameraTransmissionStatus = .local) -> ReduxState {
        let callState = CallingState(status: callingState)
        let cameraState = LocalUserState.CameraState(operation: cameraStatus,
                                                     device: cameraDeviceStatus,
                                                     transmission: cameraTransmissionStatus)
        let audioState = LocalUserState.AudioState(operation: .off,
                                                   device: .receiverSelected)
        let localState = LocalUserState(cameraState: cameraState,
                                        audioState: audioState,
                                        displayName: nil,
                                        localVideoStreamIdentifier: nil)
        let permissionState = PermissionState(audioPermission: .unknown,
                                              cameraPermission: cameraPermission)
        return AppState(callingState: callState,
                        permissionState: permissionState,
                        localUserState: localState,
                        lifeCycleState: LifeCycleState(),
                        remoteParticipantsState: .init())
    }

    private func getEmptyDispatch() -> ActionDispatch {
        return { _ in }
    }

    private func getError() -> Error {
        return NSError(domain: "", code: 100, userInfo: [
            NSLocalizedDescriptionKey: "Error"
        ])
    }

}

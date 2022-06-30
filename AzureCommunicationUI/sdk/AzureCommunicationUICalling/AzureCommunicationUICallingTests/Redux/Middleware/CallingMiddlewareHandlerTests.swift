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
            XCTAssertTrue(action == Action.localUserAction(.microphoneOffFailed(error: error)))
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestMicrophoneMute(state: getEmptyState(), dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_requestMicUnmute_when_returnsError_then_updateMicrophoneStatusIsError() {
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.microphoneOnFailed(error: error)))
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestMicrophoneUnmute(state: getEmptyState(), dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_requestCameraOn_when_cameraPermissionNotAsked_then_shouldDispatchCameraPermissionRequested() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.permissionAction(.cameraPermissionRequested))
            expectation.fulfill()
        }
        let state: AppState = getState(callingState: .connected,
                                             cameraStatus: .off,
                                             cameraDeviceStatus: .front,
                                             cameraPermission: .notAsked)

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
            XCTAssertTrue(action == Action.localUserAction(.cameraOffSucceeded))
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
            XCTAssertTrue(action == Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: videoId)))
            switch action {
            case .localUserAction(let localUserAction):
                if case let LocalUserAction.cameraOnSucceeded(videoStreamIdentifier) = localUserAction {
                    XCTAssertEqual(videoStreamIdentifier, videoId)
                    expectation.fulfill()
                }
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        callingMiddlewareHandler.requestCameraOn(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1.5)
    }

    func test_callingMiddlewareHandler_requestCameraOff_when_returnsError_then_updateCameraStatusIsError() {
        let expectation = XCTestExpectation(description: "Request Camera Off Dispatch Action Should Return Error")
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOffFailed(error: error)))
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
            XCTAssertTrue(action == Action.localUserAction(.cameraOnFailed(error: error)))
            expectation.fulfill()
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestCameraOn(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1.5)
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
            XCTAssertTrue(action == Action.localUserAction(.cameraSwitchSucceeded(cameraDevice: cameraDevice)))
            switch action {
            case let .localUserAction(.cameraSwitchSucceeded(device)):
                XCTAssertEqual(device, cameraDevice)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        callingMiddlewareHandler.requestCameraSwitch(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1.5)
    }

    func test_callingMiddlewareHandler_requestCameraSwitch_when_returnsError_then_updateCameraDeviceStatusIsError() {
        let expectation = XCTestExpectation(description: "Request Camera Switch Dispatch Action Should Return Error")
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraSwitchFailed(error: error)))
            expectation.fulfill()
        }
        mockCallingService.error = error
        callingMiddlewareHandler.requestCameraSwitch(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1.5)
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

        let errorCode = 50
        let error = getError(code: errorCode)

        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: .callEndFailed, error: error)))
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalError, err)):
                let nserror = err as? NSError
                XCTAssertEqual(nserror?.code, errorCode)
                XCTAssertEqual(internalError, .callEndFailed)
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

        let error = CallCompositeInternalError.cameraSwitchFailed

        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: error, error: nil)))
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalError, err)):
                XCTAssertEqual(internalError, error)
                XCTAssertNil(err)
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
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let errorCode = 50
        let error = getError(code: errorCode)
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: .callJoinFailed, error: error)))
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalError, err)):
                let nserror = err as? NSError
                XCTAssertEqual(nserror?.code, errorCode)
                XCTAssertEqual(internalError, .callJoinFailed)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        callingMiddlewareHandler.startCall(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_startCall_when_returnsCompositeError_then_updateClientErrorCompositeError() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let error = CallCompositeInternalError.callEndFailed

        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: error, error: nil)))
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalError, _)):
                XCTAssertEqual(internalError, error)
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
            XCTAssertTrue(action == Action.localUserAction(.cameraPreviewOnTriggered))
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
            XCTAssertTrue(action == Action.localUserAction(.cameraOnTriggered))
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
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let errorCode = 50
        let error = getError(code: errorCode)

        func dispatch(action: Action) {
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalErr, err)):
                let nserror = err as? NSError
                XCTAssertEqual(nserror!.code, errorCode)
                XCTAssertEqual(internalErr, .callJoinFailed)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        callingMiddlewareHandler.setupCall(state: getEmptyState(), dispatch: dispatch)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddlewareHandler_setupCall_when_internalErrorNotNil_then_shouldNotDispatch() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        expectation.isInverted = true

        func dispatch(action: Action) {
            XCTFail("Should not dispatch")
        }
        callingMiddlewareHandler.setupCall(state: getState(callingState: .none,
                                                           cameraStatus: .off,
                                                           cameraDeviceStatus: .front,
                                                           cameraPermission: .granted,
                                                           internalError: .callEvicted),
                                           dispatch: dispatch)
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
            XCTAssertTrue(action == Action.localUserAction(.cameraPausedSucceeded))
        }
        callingMiddlewareHandler.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_returnsError_then_updateCameraStatusIsError() {
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraPausedFailed(error: error)))
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
            XCTAssertTrue(action == Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: id)))
            switch action {
            case let .localUserAction(.cameraOnSucceeded(videoStreamIdentifier)):
                XCTAssertEqual(videoStreamIdentifier, id)
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
        wait(for: [expectation], timeout: 1.5)
    }

    func test_callingMiddlewareHandler_holdCall_then_holdCallCalled() {
        let state: AppState = getState(callingState: .connected,
                                       cameraStatus: .off,
                                       cameraDeviceStatus: .front,
                                       cameraPermission: .notAsked)

        callingMiddlewareHandler.holdCall(state: state, dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.holdCallCalled)
    }

    func test_callingMiddlewareHandler_resumeCall_then_resumeCallCalled() {
        let state: AppState = getState(callingState: .localHold,
                                       cameraStatus: .off,
                                       cameraDeviceStatus: .front,
                                       cameraPermission: .notAsked)

        callingMiddlewareHandler.resumeCall(state: state, dispatch: getEmptyDispatch())
        XCTAssertTrue(mockCallingService.resumeCallCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callLocalHold_cameraStatusOn_noError_then_updateCameraStatusOnUpdate() {
        let expectation = XCTestExpectation(description: "Dispatch the new action")
        let id = "identifier"
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: id)))
            switch action {
            case let Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier)):
                XCTAssertEqual(videoStreamIdentifier, id)
                expectation.fulfill()
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.videoStreamId = id
        callingMiddlewareHandler.enterForeground(state: getState(callingState: .localHold,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch)
        wait(for: [expectation], timeout: 1.5)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callConnected_cameraStatusOn_returnsError_then_updateCameraStatusIsError() {
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnFailed(error: error)))
        }
        mockCallingService.error = error
        callingMiddlewareHandler.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionLocal_cameraPermissionRequesting_then_updateCameraPreviewOnTriggered() {
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraPreviewOnTriggered))
        }
        callingMiddlewareHandler.onCameraPermissionIsSet(state: getState(cameraPermission: .requesting,
                                                                         cameraTransmissionStatus: .local),
                                                         dispatch: dispatch)
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionRemote_cameraPermissionRequesting_then_updateCameraOnTriggered() {
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnTriggered))
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

    private func getEmptyState() -> AppState {
        return AppState()
    }

    private func getState(callingState: CallingStatus = .none,
                          cameraStatus: LocalUserState.CameraOperationalStatus = .on,
                          cameraDeviceStatus: LocalUserState.CameraDeviceSelectionStatus = .front,
                          cameraPermission: AppPermission.Status = .unknown,
                          cameraTransmissionStatus: LocalUserState.CameraTransmissionStatus = .local,
                          internalError: CallCompositeInternalError? = nil) -> AppState {
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
        let errorState = ErrorState(internalError: internalError)
        return AppState(callingState: callState,
                        permissionState: permissionState,
                        localUserState: localState,
                        lifeCycleState: LifeCycleState(),
                        remoteParticipantsState: .init(),
                        errorState: errorState)
    }

    private func getEmptyDispatch() -> ActionDispatch {
        return { _ in }
    }

    private func getError(code: Int = 100) -> Error {
        return NSError(domain: "", code: code, userInfo: [
            NSLocalizedDescriptionKey: "Error"
        ])
    }

}

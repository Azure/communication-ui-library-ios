//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
@testable import AzureCommunicationUICalling

class CallingMiddlewareHandlerTests: XCTestCase {

    var mockCallingService: CallingServiceMocking!

    override func setUp() {
        super.setUp()
        mockCallingService = CallingServiceMocking()
    }

    override func tearDown() {
        super.tearDown()
        mockCallingService = nil
    }

    func test_callingMiddlewareHandler_requestMicMute_then_muteLocalMicCalled() async {
        let sut = makeSUT()
        await sut.requestMicrophoneMute(
            state: getEmptyState(), dispatch: getEmptyDispatch()
        ).value

        XCTAssertTrue(mockCallingService.muteLocalMicCalled)
    }

    func test_callingMiddlewareHandler_requestMicUnmute_then_unmuteLocalMicCalled() async {
        let sut = makeSUT()
        await sut.requestMicrophoneUnmute(
            state: getEmptyState(), dispatch: getEmptyDispatch()
        ).value

        XCTAssertTrue(mockCallingService.unmuteLocalMicCalled)
    }

    func test_callingMiddlewareHandler_requestMicMute_when_returnsError_then_updateMicrophoneStatusIsError() async {
        let sut = makeSUT()
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.microphoneOffFailed(error: error)))
        }
        mockCallingService.error = error
        await sut.requestMicrophoneMute(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestMicUnmute_when_returnsError_then_updateMicrophoneStatusIsError() async {
        let sut = makeSUT()
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.microphoneOnFailed(error: error)))
        }
        mockCallingService.error = error
        await sut.requestMicrophoneUnmute(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestCameraOn_when_cameraPermissionNotAsked_then_shouldDispatchCameraPermissionRequested() async {
        let sut = makeSUT()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.permissionAction(.cameraPermissionRequested))
        }
        let state: AppState = getState(callingState: .connected,
                                       cameraStatus: .off,
                                       cameraDeviceStatus: .front,
                                       cameraPermission: .notAsked)

        await sut.requestCameraOn(state: state, dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestCameraOff_then_stopLocalVideoStreamCalled() async {
        let sut = makeSUT()
        await sut.requestCameraOff(
            state: getEmptyState(), dispatch: getEmptyDispatch()
        ).value

        XCTAssertTrue(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_requestCameraOff_when_permissionNotAsked_then_updateCameraStatusOffUpdate() async {
        let sut = makeSUT()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOffSucceeded))
        }
        await sut.requestCameraOff(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestCameraOn_then_startLocalVideoStreamCalled() async {
        let sut = makeSUT()
        await sut.requestCameraOn(state: getEmptyState(), dispatch: getEmptyDispatch()).value

        XCTAssertTrue(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_requestCameraOn_when_noError_then_updateCameraStatusOnUpdate() async {
        let sut = makeSUT()
        let videoId = "Identifier"
        mockCallingService.videoStreamId = videoId
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: videoId)))
            switch action {
            case .localUserAction(let localUserAction):
                if case let LocalUserAction.cameraOnSucceeded(videoStreamIdentifier) = localUserAction {
                    XCTAssertEqual(videoStreamIdentifier, videoId)
                    }
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        await sut.requestCameraOn(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestCameraOff_when_returnsError_then_updateCameraStatusIsError() async {
        let sut = makeSUT()
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOffFailed(error: error)))
        }
        mockCallingService.error = error
        await sut.requestCameraOff(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestCameraOn_when_returnsError_then_updateCameraStatusIsError() async {
        let sut = makeSUT()
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnFailed(error: error)))
        }
        mockCallingService.error = error
        await sut.requestCameraOn(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestCameraSwitch_then_switchCameraCalled() async {
        let sut = makeSUT()
        await sut.requestCameraSwitch(
            state: getEmptyState(), dispatch: getEmptyDispatch()
        ).value

        XCTAssertTrue(mockCallingService.switchCameraCalled)
    }

    func test_callingMiddlewareHandler_requestCameraSwitch_when_noError_then_updateCameraDeviceStatusOnUpdate() async {
        let sut = makeSUT()

        let cameraDevice = CameraDevice.front
        mockCallingService.cameraDevice = cameraDevice
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraSwitchSucceeded(cameraDevice: cameraDevice)))
            switch action {
            case let .localUserAction(.cameraSwitchSucceeded(device)):
                XCTAssertEqual(device, cameraDevice)
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        await sut.requestCameraSwitch(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_requestCameraSwitch_when_returnsError_then_updateCameraDeviceStatusIsError() async {
        let sut = makeSUT()
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraSwitchFailed(error: error)))
        }
        mockCallingService.error = error
        await sut.requestCameraSwitch(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_endCall_then_endCallCalled() async {
        let sut = makeSUT()
        await sut.endCall(
            state: getEmptyState(), dispatch: getEmptyDispatch()
        ).value

        XCTAssertTrue(mockCallingService.endCallCalled)
    }

    func test_callingMiddlewareHandler_startCall_then_startCallCalled() async {
        let sut = makeSUT()
        await sut.startCall(
            state: getEmptyState(), dispatch: getEmptyDispatch()
        ).value

        XCTAssertTrue(mockCallingService.startCallCalled)
    }

    func test_callingMiddlewareHandler_endCall_when_returnNSError_then_firstUpdateCallError() async {
        let sut = makeSUT()

        let errorCode = 50
        let error = getError(code: errorCode)
        var callBackCount: Int = 0
        func dispatch(action: Action) {
            if callBackCount == 0 {
                XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: .callEndFailed, error: error)))
                switch action {
                case let .errorAction(.fatalErrorUpdated(internalError, err)):
                    let nserror = err as? NSError
                    XCTAssertEqual(nserror?.code, errorCode)
                    XCTAssertEqual(internalError, .callEndFailed)
                default:
                    XCTFail("Should not be default \(action)")
                }

                callBackCount += 1
            }
        }
        mockCallingService.error = error
        await sut.endCall(state: getEmptyState(), dispatch: dispatch).value

    }

    func test_callingMiddlewareHandler_endCall_when_returnsCompositeError_then_firstUpdateClientError() async {
        let sut = makeSUT()
        let error = CallCompositeInternalError.cameraSwitchFailed

        var callBackCount: Int = 0
        func dispatch(action: Action) {
            if callBackCount == 0 {
                XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: error, error: nil)))
                switch action {
                case let .errorAction(.fatalErrorUpdated(internalError, err)):
                    XCTAssertEqual(internalError, error)
                    XCTAssertNil(err)
                default:
                    XCTFail("Should not be default \(action)")
                }
                callBackCount += 1
            }
        }
        mockCallingService.error = error
        await sut.endCall(state: getEmptyState(), dispatch: dispatch).value

    }

    func test_callingMiddlewareHandler_endCall_when_returnNSError_then_updateRequestFailed() async {
        let sut = makeSUT()
        let errorCode = 50
        let error = getError(code: errorCode)
        var callBackCount: Int = 0
        func dispatch(action: Action) {
            if callBackCount == 0 {
                callBackCount += 1
            } else if callBackCount == 1 {
                XCTAssertTrue(action == Action.callingAction(.requestFailed))
            }
        }
        mockCallingService.error = error
        await sut.endCall(state: getEmptyState(), dispatch: dispatch).value

    }

    func test_callingMiddlewareHandler_startCall_when_returnsNSError_then_updateCallingCoreError() async {
        let sut = makeSUT()
        let errorCode = 50
        let error = getError(code: errorCode)
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: .callJoinFailed, error: error)))
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalError, err)):
                let nserror = err as? NSError
                XCTAssertEqual(nserror?.code, errorCode)
                XCTAssertEqual(internalError, .callJoinFailed)
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        await sut.startCall(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_startCall_when_returnsCompositeError_then_updateClientErrorCompositeError() async {
        let sut = makeSUT()
        let error = CallCompositeInternalError.callEndFailed

        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.errorAction(.fatalErrorUpdated(internalError: error, error: nil)))
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalError, _)):
                XCTAssertEqual(internalError, error)
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        await sut.startCall(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_setupCall_then_setupCallCalled() async {
        let sut = makeSUT()
        await sut.setupCall(
            state: getEmptyState(), dispatch: getEmptyDispatch()
        ).value
        XCTAssertTrue(mockCallingService.setupCallCalled)
    }

    func test_callingMiddlewareHandler_setupCall_when_cameraPermissionGranted_then_cameraOnTriggered() async {
        let sut = makeSUT()

        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraPreviewOnTriggered))
        }
        await sut.setupCall(state: getState(callingState: .connected,
                                                           cameraStatus: .off,
                                                           cameraDeviceStatus: .front,
                                                           cameraPermission: .granted),
                            dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_setupCall_when_cameraPermissionDenied_then_skipCameraOnTriggered() async {
        let sut = makeSUT()

        func dispatch(action: Action) {
            XCTAssertFalse(action == Action.localUserAction(.cameraOnTriggered))
        }
        await sut.setupCall(state: getState(callingState: .connected,
                                                           cameraStatus: .off,
                                                           cameraDeviceStatus: .front,
                                                           cameraPermission: .denied),
                            dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_setupCall_when_returnsError_then_updateCallingCoreError() async {
        let sut = makeSUT()
        let errorCode = 50
        let error = getError(code: errorCode)

        func dispatch(action: Action) {
            switch action {
            case let .errorAction(.fatalErrorUpdated(internalErr, err)):
                let nserror = err as? NSError
                XCTAssertEqual(nserror!.code, errorCode)
                XCTAssertEqual(internalErr, .callJoinFailed)
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.error = error
        await sut.setupCall(state: getEmptyState(), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_setupCall_when_internalErrorNotNil_then_shouldNotDispatch() async {
        let sut = makeSUT()

        func dispatch(action: Action) {
            XCTFail("Should not dispatch")
        }
        await sut.setupCall(state: getState(callingState: .none,
                                                           cameraStatus: .off,
                                                           cameraDeviceStatus: .front,
                                                           cameraPermission: .granted,
                                                           internalError: .callEvicted),
                            dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_then_cameraPausedDispatched() async {
        let sut = makeSUT()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraPausedSucceeded))
        }
        await sut.enterBackground(state: getState(
            callingState: .connected,
            cameraStatus: .on,
            cameraDeviceStatus: .front), dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_then_stopLocalVideoStreamCalled() async {
        let sut = makeSUT()
        await sut.enterBackground(
            state: getState(
                callingState: .connected,
                cameraStatus: .on,
                cameraDeviceStatus: .front),
            dispatch: getEmptyDispatch()
        ).value
        XCTAssertTrue(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterBackground_when_callNotConnected_then_stopLocalVideoStreamNotCalled() async {
        let sut = makeSUT()
        await sut.enterBackground(state: getState(callingState: .disconnected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: getEmptyDispatch()).value
        XCTAssertFalse(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterBackground_when_cameraStatusNotOn_then_stopLocalVideoStreamNotCalled() async {
        let sut = makeSUT()
        await sut.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .off,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: getEmptyDispatch()).value
        XCTAssertFalse(mockCallingService.stopLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_noError_then_updateCameraStatusPauseUpdate() async {
        let sut = makeSUT()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraPausedSucceeded))
        }
        await sut.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_enterBackground_when_callConnected_cameraStatusOn_returnsError_then_updateCameraStatusIsError() async {
        let sut = makeSUT()
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraPausedFailed(error: error)))
        }
        mockCallingService.error = error
        await sut.enterBackground(state: getState(callingState: .connected,
                                                                 cameraStatus: .on,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_enterForeground_when_callConnected_cameraStatusPaused_then_startLocalVideoStreamCalled() async {
        let sut = makeSUT()
        await sut.enterForeground(
            state: getState(callingState: .connected,
                            cameraStatus: .paused,
                            cameraDeviceStatus: .front),
            dispatch: getEmptyDispatch()
        ).value
        XCTAssertTrue(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callNotStarted_then_startLocalVideoStreamNotCalled() async {
        let sut = makeSUT()
        await sut.enterForeground(state: getState(callingState: .disconnected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: getEmptyDispatch()).value
        XCTAssertFalse(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_cameraStatusNotPaused_then_startLocalVideoStreamNotCalled() async {
        let sut = makeSUT()
        await sut.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .off,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: getEmptyDispatch()).value
        XCTAssertFalse(mockCallingService.startLocalVideoStreamCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callConnected_cameraStatusOn_noError_then_updateCameraStatusOnUpdate() async {
        let sut = makeSUT()
        let id = "identifier"
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: id)))
            switch action {
            case let .localUserAction(.cameraOnSucceeded(videoStreamIdentifier)):
                XCTAssertEqual(videoStreamIdentifier, id)
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.videoStreamId = id
        await sut.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                                 dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_holdCall_then_holdCallCalled() async {
        let sut = makeSUT()
        let state: AppState = getState(callingState: .connected,
                                       cameraStatus: .off,
                                       cameraDeviceStatus: .front,
                                       cameraPermission: .notAsked)

        await sut.holdCall(state: state, dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockCallingService.holdCallCalled)
    }

    func test_callingMiddlewareHandler_resumeCall_then_resumeCallCalled() async {
        let sut = makeSUT()
        let state: AppState = getState(callingState: .localHold,
                                       cameraStatus: .off,
                                       cameraDeviceStatus: .front,
                                       cameraPermission: .notAsked)

        await sut.resumeCall(state: state, dispatch: getEmptyDispatch()).value
        XCTAssertTrue(mockCallingService.resumeCallCalled)
    }

    func test_callingMiddlewareHandler_enterForeground_when_callLocalHold_cameraStatusOn_noError_then_updateCameraStatusOnUpdate() async {
        let sut = makeSUT()
        let id = "identifier"
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: id)))
            switch action {
            case let Action.localUserAction(.cameraOnSucceeded(videoStreamIdentifier)):
                XCTAssertEqual(videoStreamIdentifier, id)
            default:
                XCTFail("Should not be default \(action)")
            }
        }
        mockCallingService.videoStreamId = id
        await sut.enterForeground(state: getState(callingState: .localHold,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_enterForeground_when_callConnected_cameraStatusOn_returnsError_then_updateCameraStatusIsError() async {
        let sut = makeSUT()
        let error = getError()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnFailed(error: error)))
        }
        mockCallingService.error = error
        await sut.enterForeground(state: getState(callingState: .connected,
                                                                 cameraStatus: .paused,
                                                                 cameraDeviceStatus: .front),
                                  dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionLocal_cameraPermissionRequesting_then_updateCameraPreviewOnTriggered() async {
        let sut = makeSUT()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraPreviewOnTriggered))
        }
        await sut.onCameraPermissionIsSet(state: getState(cameraPermission: .requesting,
                                                                         cameraTransmissionStatus: .local),
                                          dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionRemote_cameraPermissionRequesting_then_updateCameraOnTriggered() async {
        let sut = makeSUT()
        func dispatch(action: Action) {
            XCTAssertTrue(action == Action.localUserAction(.cameraOnTriggered))
        }
        await sut.onCameraPermissionIsSet(state: getState(cameraPermission: .requesting,
                                                                         cameraTransmissionStatus: .remote),
                                          dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_onCameraPermissionIsSet_when_callTransmissionRemote_cameraPermissionNotRequesting_then_updateCameraOnTriggered() async {
        let sut = makeSUT()
        func dispatch(action: Action) {
            XCTFail("Failed with unknown action dispatched")
        }
        await sut.onCameraPermissionIsSet(state: getState(cameraPermission: .granted,
                                                                         cameraTransmissionStatus: .remote),
                                          dispatch: dispatch).value
    }

    func test_callingMiddlewareHandler_setupCall_when_networkFailed_then_shouldNotDispatch() async {
        let sut = makeSUT()

        func dispatch(action: Action) {
            XCTFail("Should not dispatch")
        }
        await sut.setupCall(state: getState(callingState: .none,
                                                           cameraStatus: .off,
                                                           cameraDeviceStatus: .front,
                                                           cameraPermission: .granted,
                                                           internalError: .connectionFailed),
                            dispatch: dispatch).value
    }
}

extension CallingMiddlewareHandlerTests {
    private func makeSUT() -> CallingMiddlewareHandler {
        let mockLogger = LoggerMocking()
        return CallingMiddlewareHandler(callingService: mockCallingService, logger: mockLogger)
    }

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

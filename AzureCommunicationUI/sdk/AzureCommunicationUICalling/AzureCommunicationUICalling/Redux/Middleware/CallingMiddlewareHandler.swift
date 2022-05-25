//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CallingMiddlewareHandling {
    func setupCall(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func startCall(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func endCall(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func holdCall(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func resumeCall(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func enterBackground(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func enterForeground(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func audioSessionInterrupted(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func audioSessionInterruptEnded(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func requestCameraPreviewOn(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func requestCameraOn(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func requestCameraOff(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func requestCameraSwitch(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func requestMicrophoneMute(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func requestMicrophoneUnmute(state: ReduxState?, dispatch: @escaping ActionDispatch)
    func onCameraPermissionIsSet(state: ReduxState?, dispatch: @escaping ActionDispatch)
}

class CallingMiddlewareHandler: CallingMiddlewareHandling {
    private let callingService: CallingServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()

    init(callingService: CallingServiceProtocol, logger: Logger) {
        self.callingService = callingService
        self.logger = logger
    }

    func setupCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState else {
            return
        }
        callingService.setupCall()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }
                switch completion {
                case .failure(let error):
                    self.handle(error: error, errorCode: CallCompositeErrorCode.callJoin, dispatch: dispatch)
                case .finished:
                    break
                }
            }, receiveValue: {
                if state.permissionState.cameraPermission == .granted,
                   state.localUserState.cameraState.operation == .off {
                    dispatch(LocalUserAction.CameraPreviewOnTriggered())
                }
            })
            .store(in: cancelBag)
    }

    func startCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState else {
            return
        }
        callingService.startCall(isCameraPreferred: state.localUserState.cameraState.operation == .on,
                                 isAudioPreferred: state.localUserState.audioState.operation == .on)
        .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else {
                return
            }

            switch completion {
            case .failure(let error):
                self.handle(error: error, errorCode: CallCompositeErrorCode.callJoin, dispatch: dispatch)
            case .finished:
                break
            }
        }, receiveValue: { _ in
            self.subscription(dispatch: dispatch)
        }).store(in: cancelBag)
    }

    func endCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        callingService.endCall()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }

                switch completion {
                case .failure(let error):
                    self.handle(error: error, errorCode: CallCompositeErrorCode.callEnd, dispatch: dispatch)
                case .finished:
                    break
                }
            }, receiveValue: { _ in })
            .store(in: cancelBag)
    }

    func holdCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState,
              state.callingState.status == .connected else {
            return
        }

        callingService.holdCall()
            .sink(receiveCompletion: { _ in

            }, receiveValue: { _ in
                self.subscription(dispatch: dispatch)
            }).store(in: cancelBag)

    }

    func resumeCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState,
              state.callingState.status == .localHold else {
            return
        }

        callingService.resumeCall()
            .sink(receiveCompletion: { _ in

            }, receiveValue: { _ in
                self.subscription(dispatch: dispatch)
            }).store(in: cancelBag)
    }

    func enterBackground(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState,
              state.callingState.status == .connected,
              state.localUserState.cameraState.operation == .on else {
            return
        }

        callingService.stopLocalVideoStream()
            .map {
                LocalUserAction.CameraPausedSucceeded()
            }.sink(receiveCompletion: {completion in
                switch completion {
                case .failure(let error):
                    dispatch(LocalUserAction.CameraPausedFailed(error: error))
                case .finished:
                    break
                }
            }, receiveValue: { newAction in
                dispatch(newAction)
            }).store(in: cancelBag)
    }

    func enterForeground(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState,
              state.callingState.status == .connected,
              state.localUserState.cameraState.operation == .paused else {
            return
        }

        requestCameraOn(state: state, dispatch: dispatch)
    }

    func requestCameraPreviewOn(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState else {
            return
        }

        if state.permissionState.cameraPermission == .notAsked {
            dispatch(PermissionAction.CameraPermissionRequested())
        } else {
            callingService.requestCameraPreviewOn().map { videoStream in
                LocalUserAction.CameraOnSucceeded(videoStreamIdentifier: videoStream)
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dispatch(LocalUserAction.CameraOnFailed(error: error))
                }
            }, receiveValue: { newAction in
                dispatch(newAction)
            }).store(in: cancelBag)
        }
    }

    func requestCameraOn(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState else {
            return
        }
        if state.permissionState.cameraPermission == .notAsked {
            dispatch(PermissionAction.CameraPermissionRequested())
        } else {
            callingService.startLocalVideoStream()
                .map { videoStream in
                    LocalUserAction.CameraOnSucceeded(videoStreamIdentifier: videoStream)
                }.sink(receiveCompletion: {completion in
                    switch completion {
                    case .failure(let error):
                        dispatch(LocalUserAction.CameraOnFailed(error: error))
                    case .finished:
                        break
                    }
                }, receiveValue: { newAction in
                    dispatch(newAction)
                }).store(in: cancelBag)
        }
    }

    func requestCameraOff(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        callingService.stopLocalVideoStream()
            .map {
                LocalUserAction.CameraOffSucceeded()
            }.sink(receiveCompletion: {completion in
                switch completion {
                case .failure(let error):
                    dispatch(LocalUserAction.CameraOffFailed(error: error))
                case .finished:
                    break
                }
            }, receiveValue: { newAction in
                dispatch(newAction)
            }).store(in: cancelBag)
    }

    func requestCameraSwitch(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        callingService.switchCamera()
            .map { cameraDevice in
                LocalUserAction.CameraSwitchSucceeded(cameraDevice: cameraDevice)
            }.sink(receiveCompletion: {completion in
                switch completion {
                case .failure(let error):
                    dispatch(LocalUserAction.CameraSwitchFailed(error: error))
                case .finished:
                    break
                }
            }, receiveValue: { newAction in
                dispatch(newAction)
            }).store(in: cancelBag)
    }

    func requestMicrophoneMute(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        callingService.muteLocalMic()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    dispatch(LocalUserAction.MicrophoneOffFailed(error: error))
                case .finished:
                    break
                }
            }, receiveValue: {}).store(in: cancelBag)
    }

    func requestMicrophoneUnmute(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        callingService.unmuteLocalMic()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    dispatch(LocalUserAction.MicrophoneOnFailed(error: error))
                case .finished:
                    break
                }
            }, receiveValue: {}).store(in: cancelBag)
    }

    func onCameraPermissionIsSet(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState,
              state.permissionState.cameraPermission == .requesting else {
            return
        }

        switch state.localUserState.cameraState.transmission {
        case .local:
            dispatch(LocalUserAction.CameraPreviewOnTriggered())
        case .remote:
            dispatch(LocalUserAction.CameraOnTriggered())
        }
    }

    func audioSessionInterrupted(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState,
              state.callingState.status == .connected else {
            return
        }

        dispatch(CallingAction.HoldRequested())
    }

    func audioSessionInterruptEnded(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        guard let state = state as? AppState,
              state.callingState.status == .localHold else {
            return
        }

        dispatch(CallingAction.ResumeRequested())
    }
}

extension CallingMiddlewareHandler {
    private func subscription(dispatch: @escaping ActionDispatch) {
        logger.debug("Subscribe to calling service subjects")
        callingService.participantsInfoListSubject
            .throttle(for: 1.25, scheduler: DispatchQueue.main, latest: true)
            .sink { list in
                let action = ParticipantListUpdated(participantsInfoList: list)
                dispatch(action)
            }.store(in: subscription)

        callingService.callInfoSubject
            .sink { [weak self] callInfoModel in
                guard let self = self else {
                    return
                }
                let errorCode = callInfoModel.errorCode
                let callingStatus = callInfoModel.status

                self.handle(callingStatus: callingStatus, dispatch: dispatch)
                self.logger.debug("Dispatch State Update: \(callingStatus)")

                self.handle(errorCode: errorCode, dispatch: dispatch) {
                    self.logger.debug("Subscription cancelled with Error Code: \(errorCode) ")
                    self.subscription.cancel()
                }

                if callingStatus == .disconnected,
                   errorCode.isEmpty {
                    self.logger.debug("Subscription cancel happy path")
                    dispatch(CompositeExitAction())
                    self.subscription.cancel()
                }
            }.store(in: subscription)

        callingService.isRecordingActiveSubject
            .removeDuplicates()
            .sink { isRecordingActive in
                let action = CallingAction.RecordingStateUpdated(isRecordingActive: isRecordingActive)
                dispatch(action)
            }.store(in: subscription)

        callingService.isTranscriptionActiveSubject
            .removeDuplicates()
            .sink { isTranscriptionActive in
                let action = CallingAction.TranscriptionStateUpdated(isTranscriptionActive: isTranscriptionActive)
                dispatch(action)
            }.store(in: subscription)

        callingService.isLocalUserMutedSubject
            .removeDuplicates()
            .sink { isLocalUserMuted in
                let action = LocalUserAction.MicrophoneMuteStateUpdated(isMuted: isLocalUserMuted)
                dispatch(action)
            }.store(in: subscription)
    }
}

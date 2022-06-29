//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CallingMiddlewareHandling {
    func setupCall(state: AppState, dispatch: @escaping ActionDispatch)
    func startCall(state: AppState, dispatch: @escaping ActionDispatch)
    func endCall(state: AppState, dispatch: @escaping ActionDispatch)
    func holdCall(state: AppState, dispatch: @escaping ActionDispatch)
    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch)
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch)
    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch)
    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch)
    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch)
    func requestCameraOn(state: AppState, dispatch: @escaping ActionDispatch)
    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch)
    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch)
    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch)
    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch)
    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch)
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

    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) {
        callingService.setupCall()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }
                switch completion {
                case .failure(let error):
                    self.handle(error: error, errorType: .callJoinFailed, dispatch: dispatch)
                case .finished:
                    break
                }
            }, receiveValue: {
                if state.permissionState.cameraPermission == .granted,
                   state.localUserState.cameraState.operation == .off,
                   state.errorState.internalError == nil {
                    dispatch(.localUserAction(.cameraPreviewOnTriggered))
                }
            })
            .store(in: cancelBag)
    }

    func startCall(state: AppState, dispatch: @escaping ActionDispatch) {
        callingService.startCall(isCameraPreferred: state.localUserState.cameraState.operation == .on,
                                 isAudioPreferred: state.localUserState.audioState.operation == .on)
        .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else {
                return
            }
            switch completion {
            case .failure(let error):
                self.handle(error: error, errorType: .callJoinFailed, dispatch: dispatch)
            case .finished:
                break
            }
        }, receiveValue: { _ in
            self.subscription(dispatch: dispatch)
        }).store(in: cancelBag)
    }

    func endCall(state: AppState, dispatch: @escaping ActionDispatch) {
        callingService.endCall()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }

                switch completion {
                case .failure(let error):
                    self.handle(error: error, errorType: .callEndFailed, dispatch: dispatch)
                case .finished:
                    break
                }
            }, receiveValue: {}).store(in: cancelBag)
    }

    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) {
        guard state.callingState.status == .connected else {
            return
        }

        callingService.holdCall()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }
                switch completion {
                case .failure(let error):
                    self.handle(error: error, errorType: .callHoldFailed, dispatch: dispatch)
                case .finished:
                    break
                }
            }, receiveValue: {}).store(in: cancelBag)

    }

    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) {
        guard state.callingState.status == .localHold else {
            return
        }

        callingService.resumeCall()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }
                switch completion {
                case .failure(let error):
                    self.handle(error: error, errorType: .callResumeFailed, dispatch: dispatch)
                case .finished:
                    break
                }
            }, receiveValue: {}).store(in: cancelBag)
    }

    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) {
        guard state.callingState.status == .connected,
              state.localUserState.cameraState.operation == .on else {
            return
        }

        callingService.stopLocalVideoStream()
            .map {
                LocalUserAction.cameraPausedSucceeded
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    dispatch(.localUserAction(.cameraPausedFailed(error: error)))
                case .finished:
                    break
                }
            }, receiveValue: { newAction in
                dispatch(.localUserAction(newAction))
            }).store(in: cancelBag)
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) {
        guard state.callingState.status == .connected || state.callingState.status == .localHold,
              state.localUserState.cameraState.operation == .paused else {
            return
        }
        requestCameraOn(state: state, dispatch: dispatch)
    }

    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) {
        if state.permissionState.cameraPermission == .notAsked {
            dispatch(.permissionAction(.cameraPermissionRequested))
        } else {
            callingService.requestCameraPreviewOn().map { videoStream in
                LocalUserAction.cameraOnSucceeded(videoStreamIdentifier: videoStream)
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dispatch(.localUserAction(.cameraOnFailed(error: error)))
                }
            }, receiveValue: { newAction in
                dispatch(.localUserAction(newAction))
            }).store(in: cancelBag)
        }
    }

    func requestCameraOn(state: AppState, dispatch: @escaping ActionDispatch) {
        if state.permissionState.cameraPermission == .notAsked {
            dispatch(.permissionAction(.cameraPermissionRequested))
        } else {
            callingService.startLocalVideoStream()
                .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
                .map { videoStream in
                    LocalUserAction.cameraOnSucceeded(videoStreamIdentifier: videoStream)
                }.sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        dispatch(.localUserAction(.cameraOnFailed(error: error)))
                    case .finished:
                        break
                    }
                }, receiveValue: { newAction in
                    dispatch(.localUserAction(newAction))
                }).store(in: cancelBag)
        }
    }

    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) {
        callingService.stopLocalVideoStream()
            .map { .cameraOffSucceeded }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        dispatch(.localUserAction(.cameraOffFailed(error: error)))
                    case .finished:
                        break
                    }
                },
                receiveValue: { dispatch(.localUserAction($0)) }
            ).store(in: cancelBag)
    }

    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) {
        callingService.switchCamera()
            .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .map { .cameraSwitchSucceeded(cameraDevice: $0) }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        dispatch(.localUserAction(.cameraSwitchFailed(error: error)) )
                    case .finished:
                        break
                    }
                },
                receiveValue: { dispatch(.localUserAction($0)) }
            )
            .store(in: cancelBag)
    }

    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) {
        callingService.muteLocalMic()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        dispatch(.localUserAction(.microphoneOffFailed(error: error)))
                    case .finished:
                        break
                    }
                }, receiveValue: {}
            )
            .store(in: cancelBag)
    }

    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) {
        callingService.unmuteLocalMic()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        dispatch(.localUserAction(.microphoneOnFailed(error: error)))
                    case .finished:
                        break
                    }
                },
                receiveValue: {}
            )
            .store(in: cancelBag)
    }

    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) {
        guard state.permissionState.cameraPermission == .requesting else {
            return
        }

        switch state.localUserState.cameraState.transmission {
        case .local:
            dispatch(.localUserAction(.cameraPreviewOnTriggered))
        case .remote:
            dispatch(.localUserAction(.cameraOnTriggered))
        }
    }

    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) {
        guard state.callingState.status == .connected else {
            return
        }

        dispatch(.callingAction(.holdRequested))
    }
}

extension CallingMiddlewareHandler {
    private func subscription(dispatch: @escaping ActionDispatch) {
        logger.debug("Subscribe to calling service subjects")
        callingService.participantsInfoListSubject
            .throttle(for: 1.25, scheduler: DispatchQueue.main, latest: true)
            .sink { list in
                dispatch(.callingAction(.participantListUpdated(participants: list)))
            }.store(in: subscription)

        callingService.callInfoSubject
            .sink { [weak self] callInfoModel in
                guard let self = self else {
                    return
                }
                let internalError = callInfoModel.internalError
                let callingStatus = callInfoModel.status

                self.handle(callingStatus: callingStatus, dispatch: dispatch)
                self.logger.debug("Dispatch State Update: \(callingStatus)")

                if let internalError = internalError {
                    self.handleCallInfo(internalError: internalError,
                                        dispatch: dispatch) {
                        self.logger.debug("Subscription cancelled with Error Code: \(internalError)")
                        self.subscription.cancel()
                    }
                    // to fix the bug that resume call won't work without Internet
                    // we exit the UI library when we receive the wrong status .remoteHold
                } else if callingStatus == .disconnected || callingStatus == .remoteHold {
                    self.logger.debug("Subscription cancel happy path")
                    dispatch(.compositeExitAction)
                    self.subscription.cancel()
                }

            }.store(in: subscription)

        callingService.isRecordingActiveSubject
            .removeDuplicates()
            .sink { isRecordingActive in
                dispatch(.callingAction(.recordingStateUpdated(isRecordingActive: isRecordingActive)))
            }.store(in: subscription)

        callingService.isTranscriptionActiveSubject
            .removeDuplicates()
            .sink { isTranscriptionActive in
                dispatch(.callingAction(.transcriptionStateUpdated(isTranscriptionActive: isTranscriptionActive)))
            }.store(in: subscription)

        callingService.isLocalUserMutedSubject
            .removeDuplicates()
            .sink { isLocalUserMuted in
                dispatch(.localUserAction(.microphoneMuteStateUpdated(isMuted: isLocalUserMuted)))
            }.store(in: subscription)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import PushKit

protocol CallingMiddlewareHandling {
    @discardableResult
    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func startCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func endCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func willTerminate(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    @discardableResult
    func registerForPushNotifications() -> Task<Void, Never>
}

class CallingMiddlewareHandler: NSObject, CallingMiddlewareHandling {
    private let callingService: CallingServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()

    private let voipRegistry = PKPushRegistry(queue: .main)

    init(callingService: CallingServiceProtocol, logger: Logger) {
        self.callingService = callingService
        self.logger = logger

        super.init()
    }

    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.setupCall()
                if state.permissionState.cameraPermission == .granted,
                   state.localUserState.cameraState.operation == .off,
                   state.errorState.internalError == nil {
                    dispatch(.localUserAction(.cameraPreviewOnTriggered))
                }
            } catch {
                handle(error: error, errorType: .callJoinFailed, dispatch: dispatch)
            }
        }
    }

    func startCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.startCall(
                    isCameraPreferred: state.localUserState.cameraState.operation == .on,
                    isAudioPreferred: state.localUserState.audioState.operation == .on
                )
                subscription(dispatch: dispatch)

//                guard currentCallUuid == nil else {
//                    return
//                }
//                let callUuid = UUID()
//                let startCallAction = CXStartCallAction(
//                    call: callUuid,
//                    handle: CXHandle(type: .generic, value: "TestCall" )   // Teams meeting or Group ID?
//                )
//                startCallAction.isVideo = state.localUserState.cameraState.operation == .on
//                let transaction = CXTransaction(action: startCallAction)
//                try await callController.request(transaction)
//                currentCallUuid = callUuid
            } catch {
                handle(error: error, errorType: .callJoinFailed, dispatch: dispatch)
            }
        }
    }

    func endCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.endCall()
                dispatch(.callingAction(.callEnded))
//                if let callUuid = currentCallUuid {
//                    try await callController.request(
//                        CXTransaction(
//                            action: CXEndCallAction(
//                                call: callUuid)
//                        )
//                    )
//                }
//                currentCallUuid = nil
            } catch {
                handle(error: error, errorType: .callEndFailed, dispatch: dispatch)
                dispatch(.callingAction(.requestFailed))
            }
        }
    }

    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            do {
                try await callingService.holdCall()
                await requestCameraPause(state: state, dispatch: dispatch).value
//                if let callUuid = currentCallUuid {
//                    try await callController.request(
//                        CXTransaction(action: CXSetHeldCallAction(call: callUuid, onHold: true))
//                    )
//                }
            } catch {
                handle(error: error, errorType: .callHoldFailed, dispatch: dispatch)
            }
        }
    }

    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .localHold else {
                return
            }

            do {
                try await callingService.resumeCall()
                if state.localUserState.cameraState.operation == .paused {
                    await requestCameraOn(state: state, dispatch: dispatch).value
                }
//                if let callUuid = currentCallUuid {
//                    try await callController.request(
//                        CXTransaction(action: CXSetHeldCallAction(call: callUuid, onHold: false))
//                    )
//                }
            } catch {
                handle(error: error, errorType: .callResumeFailed, dispatch: dispatch)
            }
        }
    }

    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            await requestCameraPause(state: state, dispatch: dispatch).value
        }
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected || state.callingState.status == .localHold,
                  state.localUserState.cameraState.operation == .paused else {
                return
            }
            await requestCameraOn(state: state, dispatch: dispatch).value
        }
    }

    func willTerminate(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }
            dispatch(.callingAction(.callEndRequested))
        }
    }

    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            if state.permissionState.cameraPermission == .notAsked {
                dispatch(.permissionAction(.cameraPermissionRequested))
            } else {
                do {
                    let identifier = try await callingService.requestCameraPreviewOn()
                    dispatch(.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: identifier)))
                } catch {
                    dispatch(.localUserAction(.cameraOnFailed(error: error)))
                }
            }
        }
    }

    func requestCameraOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            if state.permissionState.cameraPermission == .notAsked {
                dispatch(.permissionAction(.cameraPermissionRequested))
            } else {
                do {
                    let streamId = try await callingService.startLocalVideoStream()
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    dispatch(.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: streamId)))
                } catch {
                    dispatch(.localUserAction(.cameraOnFailed(error: error)))
                }
            }
        }
    }

    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.stopLocalVideoStream()
                dispatch(.localUserAction(.cameraOffSucceeded))
            } catch {
                dispatch(.localUserAction(.cameraOffFailed(error: error)))
            }
        }
    }

    func requestCameraPause(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected,
                  state.localUserState.cameraState.operation == .on else {
                return
            }

            do {
                try await callingService.stopLocalVideoStream()
                dispatch(.localUserAction(.cameraPausedSucceeded))
            } catch {
                dispatch(.localUserAction(.cameraPausedFailed(error: error)))
            }
        }
    }

    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                let device = try await callingService.switchCamera()
                try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                dispatch(.localUserAction(.cameraSwitchSucceeded(cameraDevice: device)))
            } catch {
                dispatch(.localUserAction(.cameraSwitchFailed(error: error)) )
            }
        }
    }

    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.muteLocalMic()
//                if let callUuid = currentCallUuid {
//                    try await callController.request(
//                        CXTransaction(action: CXSetMutedCallAction(call: callUuid, muted: true))
//                    )
//                }
            } catch {
                dispatch(.localUserAction(.microphoneOffFailed(error: error)))
            }
        }
    }

    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.unmuteLocalMic()
//                if let callUuid = currentCallUuid {
//                    try await callController.request(
//                        CXTransaction(action: CXSetMutedCallAction(call: callUuid, muted: false))
//                    )
//                }
            } catch {
                dispatch(.localUserAction(.microphoneOnFailed(error: error)))
            }
        }
    }

    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
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
    }

    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            dispatch(.callingAction(.holdRequested))
        }
    }

    func registerForPushNotifications() -> Task<Void, Never> {
        return Task {
            guard voipRegistry.delegate == nil else {
                return
            }

            voipRegistry.delegate = self
            // Set the push type to VoIP, which starts the registration
            voipRegistry.desiredPushTypes = [.voIP]
        }
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

extension CallingMiddlewareHandler: PKPushRegistryDelegate {

    func pushRegistry(_ registry: PKPushRegistry,
                      didUpdate pushCredentials: PKPushCredentials,
                      for type: PKPushType) {
        let token = pushCredentials.token

        // Make this a redux action dispatch?
        Task {
            try await callingService.registerForPushNotifications(token: token)
        }
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        // Process the push, start up the app straight to the call screen?
        guard type == .voIP else {
            return
        }
        Task {
            try? await callingService.handleCallSetupPush(payload: payload.dictionaryPayload)
        }
    }
}

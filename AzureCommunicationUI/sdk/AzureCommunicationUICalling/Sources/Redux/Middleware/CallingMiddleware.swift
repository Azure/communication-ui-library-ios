//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Middleware {
    static func liveCallingMiddleware(callingMiddlewareHandler actionHandler: CallingMiddlewareHandling)
    -> Middleware<AppState, AzureCommunicationUICalling.Action> {
        .init(
            apply: { dispatch, getState in
                return { next in
                    return { action in
                        switch action {
                        case .callingAction(let callingAction):
                            handleCallingAction(callingAction, actionHandler, getState, dispatch)

                        case .localUserAction(let localUserAction):
                            handleLocalUserAction(localUserAction, actionHandler, getState, dispatch)

                        case .permissionAction(let permissionAction):
                            handlePermissionAction(permissionAction, actionHandler, getState, dispatch)

                        case .lifecycleAction(let lifecycleAction):
                            handleLifecycleAction(lifecycleAction, actionHandler, getState, dispatch)

                        case .audioSessionAction(let audioAction):
                            handleAudioSessionAction(audioAction, actionHandler, getState, dispatch)
                        case .remoteParticipantsAction(let action):
                            handleRemoteParticipantAction(action, actionHandler, getState, dispatch)
                        case .captionsAction(let action):
                            handleCaptionsAction(action, actionHandler, getState, dispatch)
                        case .errorAction,
                                .compositeExitAction,
                                .callingViewLaunched:
                            break
                        default:
                            break
                        }
                        return next(action)
                    }
                }
            }
        )
    }
}

private func handleCallingAction(_ action: CallingAction,
                                 _ actionHandler: CallingMiddlewareHandling,
                                 _ getState: () -> AppState,
                                 _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .setupCall:
        actionHandler.setupCall(state: getState(), dispatch: dispatch)
    case .callStartRequested:
        actionHandler.startCall(state: getState(), dispatch: dispatch)
    case .callEndRequested:
        actionHandler.endCall(state: getState(), dispatch: dispatch)
    case .holdRequested:
        actionHandler.holdCall(state: getState(), dispatch: dispatch)
    case .resumeRequested:
        actionHandler.resumeCall(state: getState(), dispatch: dispatch)
    default:
        break
    }
}

private func handleLocalUserAction(_ action: LocalUserAction,
                                   _ actionHandler: CallingMiddlewareHandling,
                                   _ getState: () -> AppState,
                                   _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .cameraPreviewOnTriggered:
        actionHandler.requestCameraPreviewOn(state: getState(), dispatch: dispatch)
    case .cameraOnTriggered:
        actionHandler.requestCameraOn(state: getState(), dispatch: dispatch)
    case .cameraOffTriggered:
        actionHandler.requestCameraOff(state: getState(), dispatch: dispatch)
    case .cameraSwitchTriggered:
        actionHandler.requestCameraSwitch(state: getState(), dispatch: dispatch)
    case .microphoneOffTriggered:
        actionHandler.requestMicrophoneMute(state: getState(), dispatch: dispatch)
    case .microphoneOnTriggered:
        actionHandler.requestMicrophoneUnmute(state: getState(), dispatch: dispatch)

    case .cameraOnSucceeded,
            .cameraOnFailed,
            .cameraOffSucceeded,
            .cameraOffFailed,
            .cameraPausedSucceeded,
            .cameraPausedFailed,
            .cameraSwitchSucceeded,
            .cameraSwitchFailed,
            .microphoneOnFailed,
            .microphoneOffFailed,
            .microphoneMuteStateUpdated,
            .microphonePreviewOn,
            .microphonePreviewOff,
            .audioDeviceChangeRequested,
            .audioDeviceChangeSucceeded,
            .audioDeviceChangeFailed,
            .participantRoleChanged:
        break
    }
}

private func handlePermissionAction(_ action: PermissionAction,
                                    _ actionHandler: CallingMiddlewareHandling,
                                    _ getState: () -> AppState,
                                    _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .cameraPermissionGranted:
        actionHandler.onCameraPermissionIsSet(state: getState(), dispatch: dispatch)
    case .audioPermissionGranted:
        actionHandler.onMicPermissionIsGranted(state: getState(), dispatch: dispatch)
    case .audioPermissionRequested,
            .audioPermissionDenied,
            .audioPermissionNotAsked,
            .cameraPermissionRequested,
            .cameraPermissionDenied,
            .cameraPermissionNotAsked:
        break
    }
}

private func handleLifecycleAction(_ action: LifecycleAction,
                                   _ actionHandler: CallingMiddlewareHandling,
                                   _ getState: () -> AppState,
                                   _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .backgroundEntered:
        actionHandler.enterBackground(state: getState(), dispatch: dispatch)
    case .foregroundEntered:
        actionHandler.enterForeground(state: getState(), dispatch: dispatch)
    case .willTerminate:
        if getState().callingState.status == .connected {
            actionHandler.endCall(state: getState(), dispatch: dispatch)
        }
    }
}

private func handleAudioSessionAction(_ action: AudioSessionAction,
                                      _ actionHandler: CallingMiddlewareHandling,
                                      _ getState: () -> AppState,
                                      _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .audioInterrupted:
        actionHandler.audioSessionInterrupted(state: getState(), dispatch: dispatch)
    case .audioInterruptEnded,
            .audioEngaged:
        break
    }
}

private func handleRemoteParticipantAction(_ action: RemoteParticipantsAction,
                                           _ actionHandler: CallingMiddlewareHandling,
                                           _ getState: () -> AppState,
                                           _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .admitAll:
        actionHandler.admitAllLobbyParticipants(state: getState(), dispatch: dispatch)
    case .declineAll:
        actionHandler.declineAllLobbyParticipants(state: getState(), dispatch: dispatch)
    case .admit(participantId: let participantId):
        actionHandler.admitLobbyParticipant(state: getState(), dispatch: dispatch, participantId: participantId)
    case .decline(participantId: let participantId):
        actionHandler.declineLobbyParticipant(state: getState(), dispatch: dispatch, participantId: participantId)
    default:
        break
    }
}

private func handleCaptionsAction(_ action: CaptionsAction,
                                  _ actionHandler: CallingMiddlewareHandling,
                                  _ getState: () -> AppState,
                                  _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .startRequested(language: let language):
        actionHandler.startCaptions(state: getState(), dispatch: dispatch, language: language)
    case .stopRequested:
        actionHandler.stopCaptions(state: getState(), dispatch: dispatch)
    case .setSpokenLanguageRequested(language: let language):
        actionHandler.setCaptionsSpokenLanguage(state: getState(), dispatch: dispatch, language: language)
    case .setCaptionLanguageRequested(language: let language):
        actionHandler.setCaptionsLanguage(state: getState(), dispatch: dispatch, language: language)
    default:
        break
    }
}

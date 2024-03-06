//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer {
    static func appStateReducer(
        permissionsReducer: Reducer<PermissionState, PermissionAction> = .livePermissionsReducer,
        localUserReducer: Reducer<LocalUserState, LocalUserAction> = .liveLocalUserReducer,
        lifeCycleReducer: Reducer<LifeCycleState, LifecycleAction> = .liveLifecycleReducer,
        audioSessionReducer: Reducer<AudioSessionState, AudioSessionAction> = .liveAudioSessionReducer,
        callingReducer: Reducer<CallingState, Action> = .liveCallingReducer,
        navigationReducer: Reducer<NavigationState, Action> = .liveNavigationReducer,
        remoteParticipantsReducer: Reducer<RemoteParticipantsState, Action>
            = .liveRemoteParticipantsReducer,
        errorReducer: Reducer<ErrorState, Action> = .liveErrorReducer,
        visibilityReducer: Reducer<VisibilityState, VisibilityAction> = .visibilityReducer,
        diagnosticsReducer: Reducer<CallDiagnosticsState, Action> = .liveDiagnosticsReducer
    ) -> Reducer<AppState, Action> {

        return Reducer<AppState, Action> { state, action in

            var permissionState = state.permissionState
            var localUserState = state.localUserState
            var lifeCycleState = state.lifeCycleState
            var callingState = state.callingState
            var remoteParticipantState = state.remoteParticipantsState
            var navigationState = state.navigationState
            var errorState = state.errorState
            var audioSessionState = state.audioSessionState
            var diagnosticsState = state.diagnosticsState
            let defaultUserState = state.defaultUserState
            var visibilityState = state.visibilityState

            switch action {
            case let .permissionAction(permAction):
                permissionState = permissionsReducer.reduce(state.permissionState, permAction)

            case let .localUserAction(localUserAction):
                localUserState = localUserReducer.reduce(state.localUserState, localUserAction)

            case let .lifecycleAction(lifecycleAction):
                lifeCycleState = lifeCycleReducer.reduce(state.lifeCycleState, lifecycleAction)

            case let .visibilityAction(visibilityAction):
                visibilityState = visibilityReducer.reduce(state.visibilityState, visibilityAction)

            default:
                break
            }

            callingState = callingReducer.reduce(state.callingState, action)
            navigationState = navigationReducer.reduce(state.navigationState, action)
            errorState = errorReducer.reduce(state.errorState, action)
            remoteParticipantState = remoteParticipantsReducer.reduce(state.remoteParticipantsState, action)
            diagnosticsState = diagnosticsReducer.reduce(state.diagnosticsState, action)

            if case let .audioSessionAction(audioAction) = action {
                audioSessionState = audioSessionReducer.reduce(state.audioSessionState, audioAction)
            }
            return AppState(callingState: callingState,
                            permissionState: permissionState,
                            localUserState: localUserState,
                            lifeCycleState: lifeCycleState,
                            audioSessionState: audioSessionState,
                            navigationState: navigationState,
                            remoteParticipantsState: remoteParticipantState,
                            errorState: errorState,
                            defaultUserState: defaultUserState,
                            visibilityState: visibilityState,
                            diagnosticsState: diagnosticsState)
        }
    }
}

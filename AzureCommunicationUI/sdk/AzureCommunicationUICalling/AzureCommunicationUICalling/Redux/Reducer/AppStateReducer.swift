//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer {
    static func appStateReducer(
        permissionsReducer: Reducer<PermissionState, PermissionAction> = livePermissionsReducer,
        localUserReducer: Reducer<LocalUserState, LocalUserAction> = liveLocalUserReducer,
        lifeCycleReducer: Reducer<LifeCycleState, LifecycleAction> = liveLifecycleReducer,
        audioSessionReducer: Reducer<AudioSessionState, AudioSessionAction> = liveAudioSessionReducer,
        callingReducer: Reducer<CallingState, Actions> = liveCallingReducer,
        navigationReducer: Reducer<NavigationState, Actions> = liveNavigationReducer,
        errorReducer: Reducer<ErrorState, Actions> = liveErrorReducer
    ) -> Reducer<AppState, Actions> {

        return Reducer<AppState, Actions> { state, action in

            var permissionState = state.permissionState
            var localUserState = state.localUserState
            var lifeCycleState = state.lifeCycleState
            var callingState = state.callingState
            var remoteParticipantState = state.remoteParticipantsState
            var navigationState = state.navigationState
            var errorState = state.errorState
            var audioSessionState = state.audioSessionState

            if case let .permissionAction(permAction) = action {
                permissionState = permissionsReducer.reduce(state.permissionState, permAction)
            }

            if case let .localUserAction(localUserAction) = action {
                localUserState = localUserReducer.reduce(state.localUserState, localUserAction)
            }

            if case let .lifecycleAction(lifecycleAction) = action {
                lifeCycleState = lifeCycleReducer.reduce(state.lifeCycleState, lifecycleAction)
            }

            callingState = callingReducer.reduce(state.callingState, action)
            navigationState = navigationReducer.reduce(state.navigationState, action)
            errorState = errorReducer.reduce(state.errorState, action)

            if case let .audioSessionAction(audioAction) = action {
                audioSessionState = audioSessionReducer.reduce(state.audioSessionState, audioAction)
            }

            switch action {
            case .callingAction(.participantListUpdated(participants: let newParticipants)):
                remoteParticipantState = RemoteParticipantsState(participantInfoList: newParticipants)
            case .errorAction(.statusErrorAndCallReset):
                remoteParticipantState = RemoteParticipantsState(participantInfoList: [])
            default:
                break
            }
            return AppState(callingState: callingState,
                            permissionState: permissionState,
                            localUserState: localUserState,
                            lifeCycleState: lifeCycleState,
                            audioSessionState: audioSessionState,
                            navigationState: navigationState,
                            remoteParticipantsState: remoteParticipantState,
                            errorState: errorState)
        }
    }
}

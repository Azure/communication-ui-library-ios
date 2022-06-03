//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

struct AppStateReducer: Reducer {
    let permissionReducer: Reducer
    let localUserReducer: Reducer
    let lifeCycleReducer: Reducer
    let audioSessionReducer: Reducer
    let callingReducer: Reducer
    let navigationReducer: Reducer
    let errorReducer: Reducer

    init(permissionReducer: Reducer,
         localUserReducer: Reducer,
         lifeCycleReducer: Reducer,
         audioSessionReducer: Reducer,
         callingReducer: Reducer,
         navigationReducer: Reducer,
         errorReducer: Reducer) {
        self.permissionReducer = permissionReducer
        self.localUserReducer = localUserReducer
        self.lifeCycleReducer = lifeCycleReducer
        self.audioSessionReducer = audioSessionReducer
        self.callingReducer = callingReducer
        self.navigationReducer = navigationReducer
        self.errorReducer = errorReducer
    }

    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let state = state as? AppState else {
            return state
        }

        var permissionState = state.permissionState
        var localUserState = state.localUserState
        var lifeCycleState = state.lifeCycleState
        var callingState = state.callingState
        var remoteParticipantState = state.remoteParticipantsState
        var navigationState = state.navigationState
        var errorState = state.errorState
        var audioSessionState = state.audioSessionState

        if let newPermissionState = permissionReducer.reduce(state.permissionState, action) as? PermissionState {
            permissionState = newPermissionState
        }

        if let newLocalUserState = localUserReducer.reduce(state.localUserState, action) as? LocalUserState {
            localUserState = newLocalUserState
        }

        if let newLifeCycleState = lifeCycleReducer.reduce(state.lifeCycleState, action) as? LifeCycleState {
            lifeCycleState = newLifeCycleState
        }

        if let newCallingState = callingReducer.reduce(state.callingState, action) as? CallingState {
            callingState = newCallingState
        }

        if let newNaviState = navigationReducer.reduce(state.navigationState, action) as? NavigationState {
            navigationState = newNaviState
        }

        if let newErrorState = errorReducer.reduce(state.errorState, action) as? ErrorState {
            errorState = newErrorState
        }

        if let newAudioState = audioSessionReducer.reduce(state.audioSessionState, action) as? AudioSessionState {
            audioSessionState = newAudioState
        }

        switch action {
        case let action as ParticipantListUpdated:
            remoteParticipantState = RemoteParticipantsState(participantInfoList: action.participantsInfoList)
        case _ as ErrorAction.StatusErrorAndCallReset:
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

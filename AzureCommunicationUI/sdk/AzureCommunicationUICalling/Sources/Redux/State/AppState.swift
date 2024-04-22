//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct AppState {
    let callingState: CallingState
    let permissionState: PermissionState
    let localUserState: LocalUserState
    let lifeCycleState: LifeCycleState
    let visibilityState: VisibilityState
    let audioSessionState: AudioSessionState
    let remoteParticipantsState: RemoteParticipantsState
    let navigationState: NavigationState
    let errorState: ErrorState
    let defaultUserState: DefaultUserState
    let diagnosticsState: CallDiagnosticsState

    init(callingState: CallingState = .init(),
         permissionState: PermissionState = .init(),
         localUserState: LocalUserState = .init(),
         lifeCycleState: LifeCycleState = .init(),
         audioSessionState: AudioSessionState = .init(),
         navigationState: NavigationState = .init(),
         remoteParticipantsState: RemoteParticipantsState = .init(),
         errorState: ErrorState = .init(),
         defaultUserState: DefaultUserState = .init(),
         visibilityState: VisibilityState = .init(),
         diagnosticsState: CallDiagnosticsState = .init()) {
        self.callingState = callingState
        self.permissionState = permissionState
        self.localUserState = localUserState
        self.lifeCycleState = lifeCycleState
        self.audioSessionState = audioSessionState
        self.navigationState = navigationState
        self.remoteParticipantsState = remoteParticipantsState
        self.errorState = errorState
        self.defaultUserState = defaultUserState
        self.visibilityState = visibilityState
        self.diagnosticsState = diagnosticsState
    }
}

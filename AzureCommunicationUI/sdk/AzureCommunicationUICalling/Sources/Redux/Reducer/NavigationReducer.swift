//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == NavigationState,
                        Actions == Action {
    static var liveNavigationReducer: Self = Reducer { state, action in
        var navigationStatus = state.status
        switch action {
        case .callingViewLaunched:
            navigationStatus = .inCall
        case .callingAction(.dismissSetup),
                .compositeExitAction:
            navigationStatus = .exit
        case .errorAction(.statusErrorAndCallReset):
            navigationStatus = .setup

            // Exhaustive unimplemented actions
        case .audioSessionAction(_),
                .callingAction(.callIdUpdated(callId: _)),
                .callingAction(.callStartRequested),
                .callingAction(.callEndRequested),
                .callingAction(.callEnded),
                .callingAction(.requestFailed),
                .callingAction(.stateUpdated(status: _)),
                .callingAction(.setupCall),
                .callingAction(.recordingStateUpdated(isRecordingActive: _)),
                .callingAction(.transcriptionStateUpdated(isTranscriptionActive: _)),
                .callingAction(.resumeRequested),
                .callingAction(.holdRequested),
                .callingAction(.participantListUpdated(participants: _)),
                .errorAction(.fatalErrorUpdated(internalError: _, error: _)),
                .lifecycleAction(_),
                .localUserAction(_),
                .permissionAction(_):
            return state
        }
        return NavigationState(status: navigationStatus)
    }
}

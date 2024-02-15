//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == NavigationState,
                        Actions == Action {
    static var liveNavigationReducer: Self = Reducer { state, action in
        var navigationStatus = state.status
        var supportFormVisible = state.supportFormVisible
        switch action {
        case .callingViewLaunched:
            navigationStatus = .inCall
        case .callingAction(.dismissSetup),
             .errorAction(.fatalErrorUpdated),
             .compositeExitAction:
            navigationStatus = .exit
        case .errorAction(.statusErrorAndCallReset):
            navigationStatus = .setup
        case .showSupportForm:
            supportFormVisible = true
        case .hideSupportForm:
            supportFormVisible = false
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
                .lifecycleAction(_),
                .localUserAction(_),
                .remoteParticipantsAction(_),
                .permissionAction(_),
                .visibilityAction(_),
                .callDiagnosticAction(_):
            return state
        }
        return NavigationState(status: navigationStatus, supportFormVisible: supportFormVisible)
    }
}

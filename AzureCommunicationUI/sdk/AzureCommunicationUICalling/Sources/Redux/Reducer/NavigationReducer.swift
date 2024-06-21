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
        case .errorAction(.fatalErrorUpdated),
             .compositeExitAction:
            navigationStatus = .exit
        case .errorAction(.statusErrorAndCallReset):
            navigationStatus = .setup
        case .showSupportForm:
            supportFormVisible = true
        case .hideSupportForm:
            supportFormVisible = false
        case .audioSessionAction,
                .callingAction(.callIdUpdated),
                .callingAction(.callStartRequested),
                .callingAction(.callEndRequested),
                .callingAction(.callEnded),
                .callingAction(.requestFailed),
                .callingAction(.stateUpdated),
                .callingAction(.setupCall),
                .callingAction(.recordingStateUpdated),
                .callingAction(.transcriptionStateUpdated),
                .callingAction(.resumeRequested),
                .callingAction(.holdRequested),
                .lifecycleAction,
                .localUserAction,
                .remoteParticipantsAction,
                .permissionAction,
                .visibilityAction,
                .callDiagnosticAction,
                .toastNotificationAction,
                .setTotalParticipantCount:
            return state
        }
        return NavigationState(status: navigationStatus, supportFormVisible: supportFormVisible)
    }
}

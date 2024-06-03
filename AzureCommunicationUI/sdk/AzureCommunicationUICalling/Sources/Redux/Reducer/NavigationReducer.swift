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
        var endCallConfirmationVisible = state.endCallConfirmationVisible
        var audioSelectionVisible = state.audioSelectionVisible
        var moreOptionsVisible = state.moreOptionsVisible

        switch action {
        case .callingViewLaunched:
            navigationStatus = .inCall
        case .errorAction(.fatalErrorUpdated),
             .compositeExitAction:
            navigationStatus = .exit
        case .errorAction(.statusErrorAndCallReset):
            navigationStatus = .setup
        case .showSupportForm:
            audioSelectionVisible = false
            endCallConfirmationVisible = false
            supportFormVisible = true
            moreOptionsVisible = false
        case .hideSupportForm:
            supportFormVisible = false
        case .showEndCallConfirmation:
            audioSelectionVisible = false
            endCallConfirmationVisible = true
            supportFormVisible = false
            moreOptionsVisible = false
        case .hideEndCallConfirmation:
            endCallConfirmationVisible = false
        case .showMoreOptions:
            audioSelectionVisible = false
            endCallConfirmationVisible = false
            supportFormVisible = false
            moreOptionsVisible = true
        case .hideMoreOptions:
            moreOptionsVisible = false
        case .showAudioSelection:
            audioSelectionVisible = true
            endCallConfirmationVisible = false
            supportFormVisible = false
            moreOptionsVisible = false
        case .hideAudioSelection:
            audioSelectionVisible = false
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
                .callDiagnosticAction:
            return state
        }
        return NavigationState(status: navigationStatus,
                               supportFormVisible: supportFormVisible,
                               endCallConfirmationVisible: endCallConfirmationVisible,
                               audioSelectionVisible: audioSelectionVisible,
                               moreOptionsVisible: moreOptionsVisible)
    }
}

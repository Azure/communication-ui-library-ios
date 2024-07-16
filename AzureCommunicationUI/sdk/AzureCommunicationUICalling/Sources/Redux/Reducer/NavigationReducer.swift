//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == NavigationState,
                        Actions == Action {
    static var liveNavigationReducer: Self = Reducer { state, action in
        var navigationStatus = state.status
        var drawerVisibility = getDrawerVisibility(state: state)
        var selectedParticipant = state.selectedParticipant

        switch action {
        case .visibilityAction(.pipModeEntered):
            drawerVisibility = .hidden
        case .callingViewLaunched:
            navigationStatus = .inCall
            drawerVisibility = .hidden
        case .errorAction(.fatalErrorUpdated),
             .compositeExitAction:
            navigationStatus = .exit
        case .errorAction(.statusErrorAndCallReset):
            navigationStatus = .setup
        case .hideDrawer:
            selectedParticipant = nil
            drawerVisibility = .hidden
        case .showSupportForm:
            drawerVisibility = .supportFormVisible
        case .showEndCallConfirmation:
            drawerVisibility = .endCallConfirmationVisible
        case .showMoreOptions:
            drawerVisibility = .moreOptionsVisible
        case .showAudioSelection:
            drawerVisibility = .audioSelectionVisible
        case .showSupportShare:
            drawerVisibility = .supportShareSheetVisible
        case .showParticipants:
            drawerVisibility = .participantsVisible
        case .showParticipantActions(let participant):
            drawerVisibility = .participantActionsVisible
            selectedParticipant = participant
        case .localUserAction(.audioDeviceChangeRequested):
            drawerVisibility = .hidden
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
                .captionsAction,
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
        return NavigationState(status: navigationStatus,
                               supportFormVisible: supportFormVisible,
                               captionsViewVisible: captionViewVisible,
                               captionsLanguageViewVisible: captionsLanguageViewVisible,
                               spokenLanguageViewVisible: spokenLanguageViewVisible,
                               endCallConfirmationVisible: endCallConfirmationVisible,
                               audioSelectionVisible: audioSelectionVisible,
                               moreOptionsVisible: moreOptionsVisible,
                               participantsVisible: drawerVisibility.isParticipantsVisible,
                               participantActionsVisible: drawerVisibility.isParticipantActionsVisible,
                               supportShareSheetVisible: supportShareSheetVisible)
    }
}

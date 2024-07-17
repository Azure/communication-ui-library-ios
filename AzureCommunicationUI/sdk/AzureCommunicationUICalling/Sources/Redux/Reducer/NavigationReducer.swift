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
                .callingAction(.recordingUpdated),
                .callingAction(.transcriptionUpdated),
                .callingAction(.dismissRecordingTranscriptionBannedUpdated),
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
                               supportFormVisible: drawerVisibility.isSupportFormVisible,
                               endCallConfirmationVisible: drawerVisibility.isEndCallConfirmationVisible,
                               audioSelectionVisible: drawerVisibility.isAudioSelectionVisible,
                               moreOptionsVisible: drawerVisibility.isMoreOptionsVisible,
                               supportShareSheetVisible: drawerVisibility.isSupportShareSheetVisible,
                               participantsVisible: drawerVisibility.isParticipantsVisible,
                               participantActionsVisible: drawerVisibility.isParticipantActionsVisible,
                               selectedParticipant: selectedParticipant)
    }

    // Helper to track only an individual visible drawer at a time
    enum DrawerVisibility {
        case hidden
        case supportFormVisible
        case supportShareSheetVisible
        case endCallConfirmationVisible
        case audioSelectionVisible
        case moreOptionsVisible
        case participantsVisible
        case participantActionsVisible

        var isSupportFormVisible: Bool { self == .supportFormVisible }
        var isSupportShareSheetVisible: Bool { self == .supportShareSheetVisible }
        var isEndCallConfirmationVisible: Bool { self == .endCallConfirmationVisible }
        var isAudioSelectionVisible: Bool { self == .audioSelectionVisible }
        var isMoreOptionsVisible: Bool { self == .moreOptionsVisible }
        var isParticipantsVisible: Bool { self == .participantsVisible }
        var isParticipantActionsVisible: Bool { self == .participantActionsVisible }
    }

    static func getDrawerVisibility(state: NavigationState) -> DrawerVisibility {
        return state.supportFormVisible ? .supportFormVisible :
        state.supportShareSheetVisible ? .supportShareSheetVisible :
        state.endCallConfirmationVisible ? .endCallConfirmationVisible :
        state.audioSelectionVisible ? .audioSelectionVisible :
        state.participantsVisible ? .participantsVisible :
        state.participantActionsVisible ? .participantActionsVisible :
        state.moreOptionsVisible ? .moreOptionsVisible : .hidden
    }
}

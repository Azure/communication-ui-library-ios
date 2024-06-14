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
        var captionViewVisible = state.captionsViewVisible
        var captionsLanguageViewVisible = state.captionsLanguageViewVisible
        var spokenLanguageViewVisible = state.spokenLanguageViewVisible
        var supportShareSheetVisible = state.supportShareSheetVisible
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
            supportShareSheetVisible = false
            audioSelectionVisible = false
            endCallConfirmationVisible = false
            supportFormVisible = true
            captionViewVisible = false
            captionsLanguageViewVisible = false
            spokenLanguageViewVisible = false
        case .showCaptionsView:
            captionViewVisible = true
            supportFormVisible = false
            captionsLanguageViewVisible = false
            spokenLanguageViewVisible = false
        case .hideCaptionsView:
            captionViewVisible = false
            supportFormVisible = false
            captionsLanguageViewVisible = false
            spokenLanguageViewVisible = false
        case .hideSupportForm:
            supportFormVisible = false
            captionViewVisible = false
            captionsLanguageViewVisible = false
            spokenLanguageViewVisible = false
        case .showSpokenLanguageView:
            supportFormVisible = false
            captionViewVisible = false
            captionsLanguageViewVisible = false
            spokenLanguageViewVisible = true
        case .hideSpokenLanguageView:
            supportFormVisible = false
            captionViewVisible = false
            captionsLanguageViewVisible = false
            spokenLanguageViewVisible = false
        case .showCaptionsLanguageView:
            supportFormVisible = false
            captionViewVisible = false
            captionsLanguageViewVisible = true
            spokenLanguageViewVisible = false
        case .hideCaptionsLanguageView:
            supportFormVisible = false
            captionViewVisible = false
            captionsLanguageViewVisible = false
            spokenLanguageViewVisible = false
            moreOptionsVisible = false
        case .showEndCallConfirmation:
            supportShareSheetVisible = false
            audioSelectionVisible = false
            endCallConfirmationVisible = true
            supportFormVisible = false
            moreOptionsVisible = false
        case .hideEndCallConfirmation:
            endCallConfirmationVisible = false
        case .showMoreOptions:
            supportShareSheetVisible = false
            audioSelectionVisible = false
            endCallConfirmationVisible = false
            supportFormVisible = false
            moreOptionsVisible = true
        case .hideMoreOptions:
            moreOptionsVisible = false
        case .showAudioSelection:
            supportShareSheetVisible = false
            audioSelectionVisible = true
            endCallConfirmationVisible = false
            supportFormVisible = false
            moreOptionsVisible = false
        case .hideAudioSelection:
            audioSelectionVisible = false
        case .showSupportShare:
            supportShareSheetVisible = true
            audioSelectionVisible = false
            endCallConfirmationVisible = false
            supportFormVisible = false
            moreOptionsVisible = false
        case .hideSupportShare:
            supportShareSheetVisible = false
        case .localUserAction(.audioDeviceChangeRequested):
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
                .captionsAction,
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
                               captionsViewVisible: captionViewVisible,
                               captionsLanguageViewVisible: captionsLanguageViewVisible,
                               spokenLanguageViewVisible: spokenLanguageViewVisible,
                               endCallConfirmationVisible: endCallConfirmationVisible,
                               audioSelectionVisible: audioSelectionVisible,
                               moreOptionsVisible: moreOptionsVisible,
                               supportShareSheetVisible: supportShareSheetVisible)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == ErrorState,
                        Actions == Action {
    static var liveErrorReducer: Self = Reducer { state, action in

        var errorType = state.internalError
        var error = state.error
        var errorCategory = state.errorCategory

        switch action {
        case let .errorAction(.fatalErrorUpdated(internalError, rawError)):
            errorType = internalError
            error = rawError
            errorCategory = .fatal
        case let .errorAction(.statusErrorAndCallReset(internalError, rawError)):
            errorType = internalError
            error = rawError
            errorCategory = .callState
        case .callingAction(.callStartRequested):
            errorType = nil
            error = nil
            errorCategory = .none
        case .localUserAction(.cameraOnFailed):
            errorType = .cameraOnFailed
            error = nil
            errorCategory = .callState

            // Exhaustive unimplemented actions
        case .audioSessionAction,
                .callingAction(.callIdUpdated),
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
                /* <CALL_START_TIME>
                .callingAction(.callStartTimeUpdated),
                </CALL_START_TIME> */
                .lifecycleAction,
                .localUserAction,
                .permissionAction,
                .remoteParticipantsAction,
                .callDiagnosticAction,
                .compositeExitAction,
                .callingViewLaunched,
                .showSupportForm,
                .showCaptionsRttListView,
                .showSpokenLanguageView,
                .showCaptionsLanguageView,
                .captionsAction,
                .rttAction,
                .showEndCallConfirmation,
                .showMoreOptions,
                .showAudioSelection,
                .showSupportShare,
                .showParticipants,
                .showParticipantActions,
                .hideDrawer,
                .visibilityAction,
                .toastNotificationAction,
                .callScreenInfoHeaderAction,
                .setTotalParticipantCount,
                .buttonViewDataAction:
            return state
        }

        return ErrorState(internalError: errorType,
                          error: error,
                          errorCategory: errorCategory)
    }
}

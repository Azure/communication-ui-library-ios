//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

extension Reducer where State == CallingState,
                        Actions == Action {
    static var liveCallingReducer: Self = Reducer { callingState, action in

        var callingStatus = callingState.status
        var operationStatus = callingState.operationStatus
        var callIdValue = callingState.callId
        var isRecordingActive = callingState.isRecordingActive
        var isTranscriptionActive = callingState.isTranscriptionActive
        var recordingStatus = callingState.recordingStatus
        var transcriptionStatus = callingState.transcriptionStatus
        var isRecorcingTranscriptionBannedDismissed = callingState.isRecorcingTranscriptionBannedDismissed
        var callStartDate = callingState.callStartDate
        var callEndReasonCode: Int?
        var callEndReasonSubCode: Int?
        /* <CALL_START_TIME> */
        var callStartTime: Date?
        /* </CALL_START_TIME> */

        switch action {
        case .callingAction(.stateUpdated(let status, let code, let subCode)):
            callingStatus = status
            callEndReasonCode = code
            callEndReasonSubCode = subCode
        case .callingAction(.callIdUpdated(let callId)):
            callIdValue = callId
        case .callingAction(.recordingStateUpdated(let newValue)):
            isRecordingActive = newValue
            isRecorcingTranscriptionBannedDismissed = false
        case .callingAction(.transcriptionStateUpdated(let newValue)):
            isTranscriptionActive = newValue
            isRecorcingTranscriptionBannedDismissed = false
        case .callingAction(.callEndRequested):
            operationStatus = .callEndRequested
        case .callingAction(.callEnded):
            operationStatus = .callEnded
        case .callingAction(.requestFailed):
            operationStatus = .none
        case .errorAction(.statusErrorAndCallReset):
            callingStatus = .none
            operationStatus = operationStatus == .skipSetupRequested ? .skipSetupRequested : .none
            isRecordingActive = false
            isTranscriptionActive = false
        case .callingAction(.callStartRequested):
            callStartDate = Date()
        case .callingAction(.recordingUpdated(let status)):
            recordingStatus = status
        case .callingAction(.transcriptionUpdated(let status)):
            transcriptionStatus = status
        case .callingAction(.dismissRecordingTranscriptionBannedUpdated(let isDismissed)):
            isRecorcingTranscriptionBannedDismissed = isDismissed
            /* <CALL_START_TIME> */
        case .callingAction(.callStartTimeUpdated(let startTime)):
            callStartTime = startTime
            /* <CALL_START_TIME> */
        // Exhaustive un-implemented actions
        case .audioSessionAction,
                .callingAction(.setupCall),
                .callingAction(.resumeRequested),
                .callingAction(.holdRequested),
                .errorAction(.fatalErrorUpdated),
                .lifecycleAction,
                .localUserAction,
                .permissionAction,
                .remoteParticipantsAction,
                .callDiagnosticAction,
                .compositeExitAction,
                .callingViewLaunched,
                .showSupportForm,
                .showCaptionsListView,
                .showSpokenLanguageView,
                .showCaptionsLanguageView,
                .captionsAction,
                .showEndCallConfirmation,
                .showMoreOptions,
                .showAudioSelection,
                .showSupportShare,
                .visibilityAction,
                .showParticipants,
                .showParticipantActions,
                .hideDrawer,
                .toastNotificationAction,
                .callScreenInfoHeaderAction,
                .setTotalParticipantCount,
                .buttonViewDataAction:
            return callingState
        }
        return CallingState(status: callingStatus,
                            operationStatus: operationStatus,
                            callId: callIdValue,
                            isRecordingActive: isRecordingActive,
                            isTranscriptionActive: isTranscriptionActive,
                            callStartDate: callStartDate,
                            callEndReasonCode: callEndReasonCode,
                            callEndReasonSubCode: callEndReasonSubCode,
                            recordingStatus: recordingStatus,
                            transcriptionStatus: transcriptionStatus,
                            isRecorcingTranscriptionBannedDismissed: isRecorcingTranscriptionBannedDismissed,
                            /* <CALL_START_TIME> */
                            callStartTime: callStartTime
                            /* </CALL_START_TIME> */)
    }
}

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
        var callStartDate = callingState.callStartDate
        var callEndReasonCode: Int?
        var callEndReasonSubCode: Int?

        switch action {
        case .callingAction(.stateUpdated(let status, let code, let subCode)):
            callingStatus = status
            callEndReasonCode = code
            callEndReasonSubCode = subCode
        case .callingAction(.callIdUpdated(let callId)):
            callIdValue = callId
        case .callingAction(.recordingStateUpdated(let newValue)):
            isRecordingActive = newValue
        case .callingAction(.transcriptionStateUpdated(let newValue)):
            isTranscriptionActive = newValue
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
                .hideSupportForm,
                .showSupportForm,
                .showCaptionsView,
                .hideCaptionsView,
                .showSpokenLanguageView,
                .hideSpokenLanguageView,
                .showCaptionsLanguageView,
                .hideCaptionsLanguageView,
                .captionsAction,
                .hideEndCallConfirmation,
                .showEndCallConfirmation,
                .showMoreOptions,
                .hideMoreOptions,
                .showAudioSelection,
                .hideAudioSelection,
                .showSupportShare,
                .hideSupportShare,
                .visibilityAction:
            return callingState
        }
        return CallingState(status: callingStatus,
                            operationStatus: operationStatus,
                            callId: callIdValue,
                            isRecordingActive: isRecordingActive,
                            isTranscriptionActive: isTranscriptionActive,
                            callStartDate: callStartDate,
                            callEndReasonCode: callEndReasonCode,
                            callEndReasonSubCode: callEndReasonSubCode)
    }
}

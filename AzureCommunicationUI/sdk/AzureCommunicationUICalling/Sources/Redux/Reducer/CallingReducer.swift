//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == CallingState,
                        Actions == Action {
    static var liveCallingReducer: Self = Reducer { callingState, action in

        var callingStatus = callingState.status
        var operationStatus = callingState.operationStatus
        var isRecordingActive = callingState.isRecordingActive
        var isTranscriptionActive = callingState.isTranscriptionActive

        switch action {
        case .callingAction(.stateUpdated(let status)):
            callingStatus = status
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
            operationStatus = .none
            isRecordingActive = false
            isTranscriptionActive = false
        // Exhaustive un-implemented actions
        case .audioSessionAction,
                .callingAction(.callStartRequested),
                .callingAction(.setupCall),
                .callingAction(.dismissSetup),
                .callingAction(.resumeRequested),
                .callingAction(.holdRequested),
                .callingAction(.participantListUpdated(participants: _)),
                .errorAction(.fatalErrorUpdated(internalError: _, error: _)),
                .lifecycleAction(_),
                .localUserAction(_),
                .permissionAction(_),
                .compositeExitAction,
                .callingViewLaunched:
            return callingState
        }
        return CallingState(status: callingStatus,
                            operationStatus: operationStatus,
                            isRecordingActive: isRecordingActive,
                            isTranscriptionActive: isTranscriptionActive)
    }
}

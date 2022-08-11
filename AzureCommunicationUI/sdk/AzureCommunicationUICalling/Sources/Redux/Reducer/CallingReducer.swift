//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == CallingState,
                        Actions == Action {
    static var liveCallingReducer: Self = Reducer { callingState, action in

        var callingStatus = callingState.status
        var isRecordingActive = callingState.isRecordingActive
        var isTranscriptionActive = callingState.isTranscriptionActive

        switch action {
        case .callingAction(.stateUpdated(let status)):
            callingStatus = status
        case .callingAction(.recordingStateUpdated(let newValue)):
            isRecordingActive = newValue
        case .callingAction(.transcriptionStateUpdated(let newValue)):
            isTranscriptionActive = newValue
        case .errorAction(.statusErrorAndCallReset),
                .errorAction(.networkLost):
            callingStatus = .none
            isRecordingActive = false
            isTranscriptionActive = false

        // Exhaustive un-implemented actions
        case .audioSessionAction,
                .callingAction(.callStartRequested),
                .callingAction(.callEndRequested),
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
                            isRecordingActive: isRecordingActive,
                            isTranscriptionActive: isTranscriptionActive)
    }
}

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
        case .audioSessionAction(_),
                .callingAction(.callIdUpdated(callId: _)),
                .callingAction(.callEndRequested),
                .callingAction(.callEnded),
                .callingAction(.requestFailed),
                .callingAction(.stateUpdated(status: _)),
                .callingAction(.setupCall),
                .callingAction(.dismissSetup),
                .callingAction(.recordingStateUpdated(isRecordingActive: _)),
                .callingAction(.transcriptionStateUpdated(isTranscriptionActive: _)),
                .callingAction(.resumeRequested),
                .callingAction(.holdRequested),
                .callingAction(.participantListUpdated(participants: _)),
                .lifecycleAction(_),
                .localUserAction(_),
                .permissionAction(_),
                .compositeExitAction,
                .callingViewLaunched:
            return state
        }

        return ErrorState(internalError: errorType,
                          error: error,
                          errorCategory: errorCategory)
    }
}

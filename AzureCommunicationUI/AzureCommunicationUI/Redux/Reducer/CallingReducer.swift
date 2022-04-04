//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

struct CallingReducer: Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let callingState = state as? CallingState else {
            return state
        }

        var callingStatus = callingState.status
        var isRecordingActive = callingState.isRecordingActive
        var isTranscriptionActive = callingState.isTranscriptionActive
        switch action {
        case let action as CallingAction.StateUpdated:
            callingStatus = action.status
        case let action as CallingAction.RecordingStateUpdated:
            isRecordingActive = action.isRecordingActive
        case let action as CallingAction.TranscriptionStateUpdated:
            isTranscriptionActive = action.isTranscriptionActive
        case _ as ErrorAction.StatusErrorAndCallReset:
            callingStatus = .none
            isRecordingActive = false
            isTranscriptionActive = false
        default:
            return state
        }
        return CallingState(status: callingStatus,
                            isRecordingActive: isRecordingActive,
                            isTranscriptionActive: isTranscriptionActive)
    }
}

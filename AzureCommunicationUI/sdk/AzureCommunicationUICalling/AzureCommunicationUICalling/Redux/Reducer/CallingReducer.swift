//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == CallingState,
                        Action == Actions {
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
        case .errorAction(.statusErrorAndCallReset):
            callingStatus = .none
            isRecordingActive = false
            isTranscriptionActive = false
        default:
            return callingState
        }
        return CallingState(status: callingStatus,
                            isRecordingActive: isRecordingActive,
                            isTranscriptionActive: isTranscriptionActive)
    }
}

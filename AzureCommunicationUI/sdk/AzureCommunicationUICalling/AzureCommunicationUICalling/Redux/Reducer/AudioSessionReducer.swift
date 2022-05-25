//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct AudioSessionReducer: Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let audioSessionState = state as? AudioSessionState else {
            return state
        }
        var audioSessionStatus = audioSessionState.status
        switch action {
        case _ as AudioEngaged,
            _ as AudioInterruptEnded:
            audioSessionStatus = .active
        case _ as AudioInterrupted:
            audioSessionStatus = .interrupted
        default:
            return audioSessionState
        }
        return AudioSessionState(status: audioSessionStatus)
    }
}

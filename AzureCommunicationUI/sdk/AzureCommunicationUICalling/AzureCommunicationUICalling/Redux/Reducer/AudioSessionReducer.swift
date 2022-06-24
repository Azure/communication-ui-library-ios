//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

let liveAudioSessionReducer = Reducer<AudioSessionState, AudioSessionAction> { audioSessionState, action in

    var audioSessionStatus = audioSessionState.status
    switch action {
    case .audioEngaged,
            .audioInterruptEnded:
        audioSessionStatus = .active
    case .audioInterrupted:
        audioSessionStatus = .interrupted
    }
    return AudioSessionState(status: audioSessionStatus)
}

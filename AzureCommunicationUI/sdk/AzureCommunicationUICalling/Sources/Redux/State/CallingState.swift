//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CallingStatus: Int {
    case none
    case earlyMedia
    case connecting
    case ringing
    case connected
    case localHold
    case disconnecting
    case disconnected
    case inLobby
    case remoteHold
    case exited
}

struct CallingState: Equatable {
    let status: CallingStatus
    let isRecordingActive: Bool
    let isTranscriptionActive: Bool

    init(status: CallingStatus = .none,
         isRecordingActive: Bool = false,
         isTranscriptionActive: Bool = false) {
        self.status = status
        self.isRecordingActive = isRecordingActive
        self.isTranscriptionActive = isTranscriptionActive
    }

    static func == (lhs: CallingState, rhs: CallingState) -> Bool {
        return (lhs.status == rhs.status
            && lhs.isRecordingActive == rhs.isRecordingActive
            && lhs.isTranscriptionActive == rhs.isTranscriptionActive)
    }
}

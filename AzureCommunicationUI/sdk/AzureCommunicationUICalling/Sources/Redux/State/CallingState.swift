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
}

enum OperationStatus: Int {
    case none
    case callEndRequested
    case callEnded
}

struct CallingState: Equatable {
    let status: CallingStatus
    let operationStatus: OperationStatus
    let callId: String?
    let isRecordingActive: Bool
    let isTranscriptionActive: Bool

    init(status: CallingStatus = .none,
         operationStatus: OperationStatus = .none,
         callId: String? = nil,
         isRecordingActive: Bool = false,
         isTranscriptionActive: Bool = false) {
        self.status = status
        self.operationStatus = operationStatus
        self.callId = callId
        self.isRecordingActive = isRecordingActive
        self.isTranscriptionActive = isTranscriptionActive
    }

    static func == (lhs: CallingState, rhs: CallingState) -> Bool {
        return (lhs.status == rhs.status
            && lhs.isRecordingActive == rhs.isRecordingActive
            && lhs.isTranscriptionActive == rhs.isTranscriptionActive)
    }
}

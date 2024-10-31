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
    case skipSetupRequested
    case callEndRequested
    case callEnded
}

enum RecordingStatus: Equatable {
    case on
    case off
    case stopped
}

struct CallingState: Equatable {
    let status: CallingStatus
    let operationStatus: OperationStatus
    let callId: String?
    let isRecordingActive: Bool
    let isTranscriptionActive: Bool
    let recordingStatus: RecordingStatus
    let transcriptionStatus: RecordingStatus
    let isRecorcingTranscriptionBannedDismissed: Bool
    let callStartDate: Date?
    let callEndReasonCode: Int?
    let callEndReasonSubCode: Int?
    /* <CALL_START_TIME>
    let callStartTime: Date?
    </CALL_START_TIME> */

    init(status: CallingStatus = .none,
         operationStatus: OperationStatus = .none,
         callId: String? = nil,
         isRecordingActive: Bool = false,
         isTranscriptionActive: Bool = false,
         callStartDate: Date? = nil,
         callEndReasonCode: Int? = nil,
         callEndReasonSubCode: Int? = nil,
         recordingStatus: RecordingStatus = RecordingStatus.off,
         transcriptionStatus: RecordingStatus = RecordingStatus.off,
         isRecorcingTranscriptionBannedDismissed: Bool = false,
         /* <CALL_START_TIME> */
         callStartTime: Date? = nil
         /* </CALL_START_TIME> */) {
        self.status = status
        self.operationStatus = operationStatus
        self.callId = callId
        self.isRecordingActive = isRecordingActive
        self.isTranscriptionActive = isTranscriptionActive
        self.callStartDate = callStartDate
        self.callEndReasonCode = callEndReasonCode
        self.callEndReasonSubCode = callEndReasonSubCode
        self.recordingStatus = recordingStatus
        self.transcriptionStatus = transcriptionStatus
        self.isRecorcingTranscriptionBannedDismissed = isRecorcingTranscriptionBannedDismissed
        /* <CALL_START_TIME>
        self.callStartTime = callStartTime
        </CALL_START_TIME> */
    }

    static func == (lhs: CallingState, rhs: CallingState) -> Bool {
        return (lhs.status == rhs.status
            && lhs.isRecordingActive == rhs.isRecordingActive
            && lhs.isTranscriptionActive == rhs.isTranscriptionActive)
    }
}

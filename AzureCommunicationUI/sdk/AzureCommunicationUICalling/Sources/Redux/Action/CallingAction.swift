//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CallingAction: Equatable {
    case callStartRequested
    case callEndRequested
    case callEnded
    case stateUpdated(status: CallingStatus)

    case callIdUpdated(callId: String)

    case setupCall
    case dismissSetup
    case recordingStateUpdated(isRecordingActive: Bool)

    case transcriptionStateUpdated(isTranscriptionActive: Bool)

    case resumeRequested
    case holdRequested
    case requestFailed
    case participantListUpdated(participants: [ParticipantInfoModel])
}

enum ErrorAction: Equatable {
    static func == (lhs: ErrorAction, rhs: ErrorAction) -> Bool {
        switch (lhs, rhs) {
        case let (.fatalErrorUpdated(internalError: lErr, error: _),
                  .fatalErrorUpdated(internalError: rErr, error: _)):
            return lErr == rErr
        case let (.statusErrorAndCallReset(internalError: lErr, error: _),
                  .statusErrorAndCallReset(internalError: rErr, error: _)):
            return lErr == rErr
        default:
            return false
        }
    }

    case fatalErrorUpdated(internalError: CallCompositeInternalError, error: Error?)
    case statusErrorAndCallReset(internalError: CallCompositeInternalError, error: Error?)
}

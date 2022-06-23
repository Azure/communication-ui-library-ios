//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CallingAction {
    case callStartRequested
    case callEndRequested
    case stateUpdated(status: CallingStatus)

    case setupCall
    case dismissSetup
    case recordingStateUpdated(isRecordingActive: Bool)

    case transcriptionStateUpdated(isTranscriptionActive: Bool)

    case resumeRequested
    case holdRequested
    case participantListUpdated(participants: [ParticipantInfoModel])
}

enum ErrorAction {
    case fatalErrorUpdated(internalError: CallCompositeInternalError, error: Error?)
    case statusErrorAndCallReset(internalError: CallCompositeInternalError, error: Error?)
}

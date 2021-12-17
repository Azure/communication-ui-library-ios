//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct CallingAction {
    struct CallStartRequested: Action {}

    struct CallEndRequested: Action {}

    struct StateUpdated: Action {
        let status: CallingStatus
    }

    struct SetupCall: Action {}

    struct DismissSetup: Action {}

    struct RecordingStateUpdated: Action {
        let isRecordingActive: Bool
    }

    struct TranscriptionStateUpdated: Action {
        let isTranscriptionActive: Bool
    }

    struct CleanupCallStates: Action {}
}

struct ParticipantListUpdated: Action {
    let participantsInfoList: [ParticipantInfoModel]
}

struct ErrorAction: Action {
    struct FatalErrorUpdated: Action {
        let error: ErrorEvent
        let errorCode: String
    }

    struct CallStateErrorUpdated: Action {
        let error: ErrorEvent
        let errorCode: String
    }
}

struct CompositeExitAction: Action {}

struct CallingViewLaunched: Action {}

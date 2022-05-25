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

    struct ResumeRequested: Action {}
    struct HoldRequested: Action {}
}

struct ParticipantListUpdated: Action {
    let participantsInfoList: [ParticipantInfoModel]
}

struct ErrorAction: Action {
    struct FatalErrorUpdated: Action {
        let error: CommunicationUIErrorEvent
    }

    struct StatusErrorAndCallReset: Action {
        let error: CommunicationUIErrorEvent
    }
}

struct CompositeExitAction: Action {}

struct CallingViewLaunched: Action {
}

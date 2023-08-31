//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

enum NetworkDiagnostic {
    case networkReconnectionQuality
    case networkReceiveQuality
    case networkSendQuality
    case networkUnavailable
    case networkRelaysUnreachable
}

enum MediaDiagnostic {
    case speakerNotFunctioning
    case speakerBusy
    case speakerMuted
    case speakerVolumeZero
    case noSpeakerDevicesAvailable
    case speakingWhileMicrophoneIsMuted
    case noMicrophoneDevicesAvailable
    case microphoneBusy
    case cameraFrozen
    case cameraStartFailed
    case cameraStartTimedOut
    case microphoneNotFunctioning
    case microphoneMutedUnexpectedly
    case cameraPermissionDenied
}

struct NetworkQualityDiagnosticModel {
    var diagnostic: NetworkDiagnostic
    var value: DiagnosticQuality
}

struct NetworkDiagnosticModel {
    var diagnostic: NetworkDiagnostic
    var value: Bool
}

struct MediaDiagnosticModel {
    var diagnostic: MediaDiagnostic
    var value: Bool
}

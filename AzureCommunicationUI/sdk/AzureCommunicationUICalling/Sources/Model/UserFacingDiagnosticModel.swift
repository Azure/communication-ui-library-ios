//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

enum NetworkCallDiagnostic: String, CaseIterable, Equatable {
    case networkUnavailable
    case networkRelaysUnreachable
}

enum NetworkQualityCallDiagnostic: String, CaseIterable, Equatable {
    case networkReconnectionQuality
    case networkReceiveQuality
    case networkSendQuality
}

enum MediaCallDiagnostic: String, CaseIterable, Equatable {
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

struct CallDiagnosticModel<DiagnosticKind, Value>: Equatable
  where DiagnosticKind: Equatable, Value: Equatable {

    var diagnostic: DiagnosticKind
    var value: Value
}

enum CallDiagnosticQuality: Int {
    case unknown
    case good
    case poor
    case bad
}

typealias NetworkQualityDiagnosticModel =
    CallDiagnosticModel<NetworkQualityCallDiagnostic, CallDiagnosticQuality>

typealias NetworkDiagnosticModel = CallDiagnosticModel<NetworkCallDiagnostic, Bool>

typealias MediaDiagnosticModel = CallDiagnosticModel<MediaCallDiagnostic, Bool>

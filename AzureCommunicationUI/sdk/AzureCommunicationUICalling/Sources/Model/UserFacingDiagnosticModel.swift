//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

enum NetworkCallDiagnostic: String {
    case networkReconnectionQuality
    case networkReceiveQuality
    case networkSendQuality
    case networkUnavailable
    case networkRelaysUnreachable
}

enum MediaCallDiagnostic: String {
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

typealias NetworkQualityDiagnosticModel =
    CallDiagnosticModel<NetworkCallDiagnostic, DiagnosticQuality>

typealias NetworkDiagnosticModel = CallDiagnosticModel<NetworkCallDiagnostic, Bool>

typealias MediaDiagnosticModel = CallDiagnosticModel<MediaCallDiagnostic, Bool>

extension DiagnosticQuality: CustomStringConvertible {
    public var description: String {
        switch self {
        case .good:
            return "good"
        case .poor:
            return "poor"
        case .bad:
            return "bad"
        case .unknown:
            fallthrough
        @unknown default:
            return "unknown"
        }
    }
}

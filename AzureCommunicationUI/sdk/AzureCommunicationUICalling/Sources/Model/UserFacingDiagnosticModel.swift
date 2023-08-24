//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

enum NetworkDiagnostic: String {
    case networkReconnectionQuality = "network_reconnection_quality"
    case networkReceiveQuality = "network_receive_quality"
    case networkSendQuality = "network_send_quality"
    case networkUnavailable = "network_unavailable"
    case networkRelaysUnreachable = "network_relays_unreachable"
}

enum MediaDiagnostic: String {
    case speakerNotFunctioning = "speaker_not_functioning"
    case speakerBusy = "speaker_busy"
    case speakerMuted = "speaker_muted"
    case speakerVolumeZero = "speaker_volume_zero"
    case noSpeakerDevicesAvailable = "no_speaker_devices_available"
    case speakingWhileMicrophoneIsMuted = "speaking_while_microphone_is_muted"
    case noMicrophoneDevicesAvaliable = "no_microphone_devices_available"
    case microphoneBusy = "microphone_busy"
    case cameraFrozen = "camera_frozen"
    case cameraStartFailed = "camera_start_failed"
    case cameraStartTimedOut = "camera_start_timed_out"
    case microphoneNotFunctioning = "microphone_not_functioning"
    case microphoneMutedUnexpectedly = "microphone_muted_unexpectedly"
    case cameraPermissionDenied = "camera_permission_denied"
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

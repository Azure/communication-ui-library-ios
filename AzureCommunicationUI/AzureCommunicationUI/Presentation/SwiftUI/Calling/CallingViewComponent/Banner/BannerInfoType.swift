//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

enum BannerInfoType: Equatable {
    case recordingAndTranscriptionStarted
    case recordingStarted
    case transcriptionStoppedStillRecording
    case transcriptionStarted
    case transcriptionStoppedAndSaved
    case recordingStoppedStillTranscribing
    case recordingStopped
    case recordingAndTranscriptionStopped

    var title: String {
        switch self {
        case .recordingAndTranscriptionStarted:
            return "Recording and transcription have started. "
        case .recordingStarted:
            return "Recording has started. "
        case .transcriptionStoppedStillRecording:
            return "Transcription has stopped. "
        case .transcriptionStarted:
            return "Transcription has started. "
        case .transcriptionStoppedAndSaved:
            return "Transcription is being saved. "
        case .recordingStoppedStillTranscribing:
            return "Recording has stopped. "
        case .recordingStopped:
            return "Recording is being saved. "
        case .recordingAndTranscriptionStopped:
            return "Recording and transcription are being saved. "
        }
    }

    var body: String {
        switch self {
        case .recordingAndTranscriptionStarted,
                .recordingStarted,
                .transcriptionStarted:
            return "By joining, you are giving consent for this meeting to be transcribed. "
        case .transcriptionStoppedStillRecording:
            return "You are now only recording this meeting. "
        case .transcriptionStoppedAndSaved:
            return "Transcription has stopped. "
        case .recordingStoppedStillTranscribing:
            return "You are now only transcribing this meeting. "
        case .recordingStopped:
            return "Recording has stopped. "
        case .recordingAndTranscriptionStopped:
            return "Recording and transcription have stopped. "
        }
    }

    var linkDisplay: String {
        switch self {
        case .recordingAndTranscriptionStarted,
                .recordingStarted,
                .transcriptionStoppedStillRecording,
                .transcriptionStarted,
                .recordingStoppedStillTranscribing:
            return "Privacy policy"
        case .transcriptionStoppedAndSaved,
                .recordingStopped,
                .recordingAndTranscriptionStopped:
            return "Learn more"
        }
    }

    var link: String {
        switch self {
        case .recordingAndTranscriptionStarted,
                .recordingStarted,
                .transcriptionStoppedStillRecording,
                .transcriptionStarted,
                .recordingStoppedStillTranscribing:
            return "https://privacy.microsoft.com/en-US/privacystatement#mainnoticetoendusersmodule"
        case .transcriptionStoppedAndSaved,
                .recordingStopped,
                .recordingAndTranscriptionStopped:
            return ("https://support.microsoft.com/en-us/office/"
                    + "record-a-meeting-in-teams-34dfbe7f-b07d-4a27-b4c6-de62f1348c24")
        }
    }
}

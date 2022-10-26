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

    var title: LocalizationKey {
        switch self {
        case .recordingAndTranscriptionStarted:
            return .bannerTitleRecordingAndTranscriptionStarted
        case .recordingStarted:
            return .bannerTitleReordingStarted
        case .transcriptionStoppedStillRecording:
            return .bannerTitleTranscriptionStoppedStillRecording
        case .transcriptionStarted:
            return .bannerTitleTranscriptionStarted
        case .transcriptionStoppedAndSaved:
            return .bannerTitleTranscriptionStopped
        case .recordingStoppedStillTranscribing:
            return .bannerTitleRecordingStoppedStillTranscribing
        case .recordingStopped:
            return .bannerTitleRecordingStopped
        case .recordingAndTranscriptionStopped:
            return .bannerTitleRecordingAndTranscribingStopped
        }
    }

    var body: LocalizationKey {
        switch self {
        case .recordingAndTranscriptionStarted,
             .recordingStarted,
             .transcriptionStarted:
            return .bannerBodyConsent
        case .transcriptionStoppedStillRecording:
            return .bannerBodyRecording
        case .transcriptionStoppedAndSaved:
            return .bannerBodyTranscriptionStopped
        case .recordingStoppedStillTranscribing:
            return .bannerBodyOnlyTranscribing
        case .recordingStopped:
            return .bannerBodyRecordingStopped
        case .recordingAndTranscriptionStopped:
            return .bannerBodyRecordingAndTranscriptionStopped
        }
    }

    var linkDisplay: LocalizationKey {
        switch self {
        case .recordingAndTranscriptionStarted,
             .recordingStarted,
             .transcriptionStoppedStillRecording,
             .transcriptionStarted,
             .recordingStoppedStillTranscribing:
            return .bannerDisplayLinkPrivacyPolicy
        case .transcriptionStoppedAndSaved,
             .recordingStopped,
             .recordingAndTranscriptionStopped:
            return .bannerDisplayLinkLearnMore
        }
    }

    var link: String {
        switch self {
        case .recordingAndTranscriptionStarted,
             .recordingStarted,
             .transcriptionStoppedStillRecording,
             .transcriptionStarted,
             .recordingStoppedStillTranscribing:
            return StringConstants.privacyPolicyLink
        case .transcriptionStoppedAndSaved,
             .recordingStopped,
             .recordingAndTranscriptionStopped:
            return StringConstants.learnMoreLink
        }
    }
}

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

    func getTitle(_ localizationProvider: LocalizationProvider) -> String {
        switch self {
        case .recordingAndTranscriptionStarted:
            return localizationProvider.getLocalizedString(.bannerTitleRecordingAndTranscriptionStarted)
        case .recordingStarted:
            return localizationProvider.getLocalizedString(.bannerTitleReordingStarted)
        case .transcriptionStoppedStillRecording:
            return localizationProvider.getLocalizedString(.bannerTitleTranscriptionStoppedStillRecording)
        case .transcriptionStarted:
            return localizationProvider.getLocalizedString(.bannerTitleTranscriptionStarted)
        case .transcriptionStoppedAndSaved:
            return localizationProvider.getLocalizedString(.bannerTitleTranscriptionStopped)
        case .recordingStoppedStillTranscribing:
            return localizationProvider.getLocalizedString(.bannerTitleRecordingStoppedStillTranscribing)
        case .recordingStopped:
            return localizationProvider.getLocalizedString(.bannerTitleRecordingStopped)
        case .recordingAndTranscriptionStopped:
            return localizationProvider.getLocalizedString(.bannerTitleRecordingAndTranscribingStopped)
        }
    }

    func getBody(_ localizationProvider: LocalizationProvider) -> String {
        switch self {
        case .recordingAndTranscriptionStarted,
             .recordingStarted,
             .transcriptionStarted:
            return localizationProvider.getLocalizedString(.bannerBodyConsent)
        case .transcriptionStoppedStillRecording:
            return localizationProvider.getLocalizedString(.bannerBodyRecording)
        case .transcriptionStoppedAndSaved:
            return localizationProvider.getLocalizedString(.bannerBodyTranscriptionStopped)
        case .recordingStoppedStillTranscribing:
            return localizationProvider.getLocalizedString(.bannerBodyOnlyTranscribing)
        case .recordingStopped:
            return localizationProvider.getLocalizedString(.bannerBodyRecordingStopped)
        case .recordingAndTranscriptionStopped:
            return localizationProvider.getLocalizedString(.bannerBodyRecordingAndTranscriptionStopped)
        }
    }

    func getLinkDisplay(_ localizationProvider: LocalizationProvider) -> String {
        switch self {
        case .recordingAndTranscriptionStarted,
             .recordingStarted,
             .transcriptionStoppedStillRecording,
             .transcriptionStarted,
             .recordingStoppedStillTranscribing:
            return localizationProvider.getLocalizedString(.bannerDisplayLinkPrivacyPolicy)
        case .transcriptionStoppedAndSaved,
             .recordingStopped,
             .recordingAndTranscriptionStopped:
            return localizationProvider.getLocalizedString(.bannerDisplayLinkLearnMore)
        }
    }

    func getLink() -> String {
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

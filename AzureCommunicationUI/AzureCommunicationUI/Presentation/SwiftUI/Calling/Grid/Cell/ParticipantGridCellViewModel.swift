//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

struct ParticipantVideoViewInfoModel {
    let videoStreamType: VideoStreamInfoModel.MediaStreamType?
    let videoStreamId: String?
}

class ParticipantGridCellViewModel: ObservableObject, Identifiable {
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol

    let id = UUID()

    @Published var videoViewModel: ParticipantVideoViewInfoModel?
    @Published var accessibilityLabel: String = ""
    @Published var displayName: String?
    @Published var isSpeaking: Bool
    @Published var isMuted: Bool

    var participantIdentifier: String
    private var isScreenSharing: Bool = false

    init(localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         participantModel: ParticipantInfoModel) {
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.displayName = participantModel.displayName
        self.isSpeaking = participantModel.isSpeaking
        self.participantIdentifier = participantModel.userIdentifier
        self.isMuted = participantModel.isMuted
        self.videoViewModel = getDisplayingVideoStreamModel(participantModel)
        self.accessibilityLabel = getAccessibilityLabel(participantModel: participantModel)
    }

    func update(participantModel: ParticipantInfoModel) {
        self.participantIdentifier = participantModel.userIdentifier
        let videoViewModel = getDisplayingVideoStreamModel(participantModel)

        if self.videoViewModel?.videoStreamId != videoViewModel.videoStreamId ||
            self.videoViewModel?.videoStreamType != videoViewModel.videoStreamType {
            let newIsScreenSharing = videoViewModel.videoStreamType == .screenSharing
            if newIsScreenSharing {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.screenshareStartAccessibilityLabel))
            } else if self.isScreenSharing && !newIsScreenSharing {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.screenshareEndAccessibilityLabel))
            }
            self.isScreenSharing = newIsScreenSharing
            self.videoViewModel = ParticipantVideoViewInfoModel(videoStreamType: videoViewModel.videoStreamType,
                                                 videoStreamId: videoViewModel.videoStreamId)
        }

        if self.displayName != participantModel.displayName || self.isMuted != participantModel.isMuted {
            self.accessibilityLabel = getAccessibilityLabel(participantModel: participantModel)
        }

        if self.displayName != participantModel.displayName {
            self.displayName = participantModel.displayName
        }

        if self.isSpeaking != participantModel.isSpeaking {
            self.isSpeaking = participantModel.isSpeaking
        }

        if self.isMuted != participantModel.isMuted {
            self.isMuted = participantModel.isMuted
        }
    }

    private func getAccessibilityLabel(participantModel: ParticipantInfoModel) -> String {
        return participantModel.displayName
        + localizationProvider.getLocalizedString(participantModel.isMuted ? .muted : .unmuted)
    }

    private func getDisplayingVideoStreamModel(_ participantModel: ParticipantInfoModel)
    -> ParticipantVideoViewInfoModel {
        let screenShareVideoStreamIdentifier = participantModel.screenShareVideoStreamModel?.videoStreamIdentifier
        let cameraVideoStreamIdentifier = participantModel.cameraVideoStreamModel?.videoStreamIdentifier
        let screenShareVideoStreamType = participantModel.screenShareVideoStreamModel?.mediaStreamType
        let cameraVideoStreamType = participantModel.cameraVideoStreamModel?.mediaStreamType

        return screenShareVideoStreamIdentifier != nil ?
        ParticipantVideoViewInfoModel(videoStreamType: screenShareVideoStreamType,
                                      videoStreamId: screenShareVideoStreamIdentifier) :
        ParticipantVideoViewInfoModel(videoStreamType: cameraVideoStreamType,
                                      videoStreamId: cameraVideoStreamIdentifier)
    }
}

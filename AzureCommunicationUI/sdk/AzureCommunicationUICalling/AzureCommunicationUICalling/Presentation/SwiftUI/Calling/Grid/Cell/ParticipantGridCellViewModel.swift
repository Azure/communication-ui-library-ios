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
    @Published var participantIdentifier: String
    private var isScreenSharing: Bool = false
    private var participantName: String
    private var renderDisplayName: String?

    init(localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         participantModel: ParticipantInfoModel) {
        print("!!! init")
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.participantName = participantModel.displayName
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
print("!!! update")
        if self.videoViewModel?.videoStreamId != videoViewModel.videoStreamId ||
            self.videoViewModel?.videoStreamType != videoViewModel.videoStreamType {
            print("!!!!!! 1 check \(self.videoViewModel?.videoStreamId != videoViewModel.videoStreamId)")
            print("!!!!!! 2 check \(self.videoViewModel?.videoStreamType != videoViewModel.videoStreamType)")
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

        if self.participantName != participantModel.displayName || self.isMuted != participantModel.isMuted {
            self.accessibilityLabel = getAccessibilityLabel(participantModel: participantModel)
        }

        if self.participantName != participantModel.displayName {
            self.participantName = participantModel.displayName
            updateParticipantNameIfNeeded(with: renderDisplayName)
        }

        if self.isSpeaking != participantModel.isSpeaking {
            self.isSpeaking = participantModel.isSpeaking
        }

        if self.isMuted != participantModel.isMuted {
            self.isMuted = participantModel.isMuted
        }
    }

    func updateParticipantNameIfNeeded(with renderDisplayName: String?) {
        self.renderDisplayName = renderDisplayName
        guard renderDisplayName != displayName else {
            return
        }

        let name: String
        if let renderDisplayName = renderDisplayName {
            let isRendererNameEmpty = renderDisplayName.trimmingCharacters(in: .whitespaces).isEmpty
            name = isRendererNameEmpty ? participantName : renderDisplayName
        } else {
            name = participantName
        }
        displayName = name
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

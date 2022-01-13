//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling

class ParticipantGridCellViewModel: ObservableObject, Identifiable {
    let id = UUID()

    @Published var videoStreamId: String?
    @Published var videoStreamType: VideoStreamInfoModel.MediaStreamType?
    @Published var displayName: String?
    @Published var isSpeaking: Bool
    @Published var isMuted: Bool
    var participantIdentifier: String

    init(compositeViewModelFactory: CompositeViewModelFactory,
         participantModel: ParticipantInfoModel) {
        self.displayName = participantModel.displayName
        self.isSpeaking = participantModel.isSpeaking
        self.participantIdentifier = participantModel.userIdentifier
        self.isMuted = participantModel.isMuted
        self.videoStreamId = getDisplayingVideoStreamId(participantModel)
        self.videoStreamType = getDisplayingVideoStreamType(participantModel)
    }

    func update(participantModel: ParticipantInfoModel) {
        self.participantIdentifier = participantModel.userIdentifier
        let videoIdentifier = getDisplayingVideoStreamId(participantModel)

        if self.videoStreamId != videoIdentifier {
            self.videoStreamId = videoIdentifier
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

    private func getDisplayingVideoStreamId(_ participantModel: ParticipantInfoModel) -> String? {
        let screenShareVideoStreamIdentifier = participantModel.screenShareVideoStreamModel?.videoStreamIdentifier
        let cameraVideoStreamIdentifier = participantModel.cameraVideoStreamModel?.videoStreamIdentifier
        return screenShareVideoStreamIdentifier ?? cameraVideoStreamIdentifier
    }

    private func getDisplayingVideoStreamType(
        _ participantModel: ParticipantInfoModel) -> VideoStreamInfoModel.MediaStreamType? {
        let screenShareVideoStreamType = participantModel.screenShareVideoStreamModel?.mediaStreamType
        let cameraVideoStreamType = participantModel.cameraVideoStreamModel?.mediaStreamType
        return screenShareVideoStreamType ?? cameraVideoStreamType
    }
}

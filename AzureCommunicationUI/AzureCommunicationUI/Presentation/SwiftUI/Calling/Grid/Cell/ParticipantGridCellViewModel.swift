//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

struct VideoViewModel {
    let videoStreamType: VideoStreamInfoModel.MediaStreamType?
    let videoStreamId: String?
}

class ParticipantGridCellViewModel: ObservableObject, Identifiable {
    let id = UUID()

    @Published var videoViewModel: VideoViewModel?
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
        self.videoViewModel = getDisplayingVideoStreamModel(participantModel)
    }

    func update(participantModel: ParticipantInfoModel) {
        self.participantIdentifier = participantModel.userIdentifier
        let videoViewModel = getDisplayingVideoStreamModel(participantModel)

        if self.videoViewModel?.videoStreamId != videoViewModel.videoStreamId ||
            self.videoViewModel?.videoStreamType != videoViewModel.videoStreamType {
            self.videoViewModel = VideoViewModel(videoStreamType: videoViewModel.videoStreamType,
                                                 videoStreamId: videoViewModel.videoStreamId)
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

    private func getDisplayingVideoStreamModel(_ participantModel: ParticipantInfoModel) -> VideoViewModel {
        let screenShareVideoStreamIdentifier = participantModel.screenShareVideoStreamModel?.videoStreamIdentifier
        let cameraVideoStreamIdentifier = participantModel.cameraVideoStreamModel?.videoStreamIdentifier
        let screenShareVideoStreamType = participantModel.screenShareVideoStreamModel?.mediaStreamType
        let cameraVideoStreamType = participantModel.cameraVideoStreamModel?.mediaStreamType

        return screenShareVideoStreamIdentifier != nil ?
        VideoViewModel(videoStreamType: screenShareVideoStreamType, videoStreamId: screenShareVideoStreamIdentifier) :
        VideoViewModel(videoStreamType: cameraVideoStreamType, videoStreamId: cameraVideoStreamIdentifier)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

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
        self.videoStreamId = getDisplayingVideoStreamIdAndType(participantModel).0
        self.videoStreamType = getDisplayingVideoStreamIdAndType(participantModel).1
    }

    func update(participantModel: ParticipantInfoModel) {
        self.participantIdentifier = participantModel.userIdentifier
        let videoIdentifier = getDisplayingVideoStreamIdAndType(participantModel).0
        let videoStreamType = getDisplayingVideoStreamIdAndType(participantModel).1

        if self.videoStreamId != videoIdentifier {
            self.videoStreamId = videoIdentifier
        }

        if self.videoStreamType != videoStreamType {
            self.videoStreamType = videoStreamType
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

    private func getDisplayingVideoStreamIdAndType(_ participantModel: ParticipantInfoModel) ->
                                           (String?, VideoStreamInfoModel.MediaStreamType?) {
        let screenShareVideoStreamIdentifier = participantModel.screenShareVideoStreamModel?.videoStreamIdentifier
        let cameraVideoStreamIdentifier = participantModel.cameraVideoStreamModel?.videoStreamIdentifier
        let screenShareVideoStreamType = participantModel.screenShareVideoStreamModel?.mediaStreamType
        let cameraVideoStreamType = participantModel.cameraVideoStreamModel?.mediaStreamType
        let cameraVideoPair = (cameraVideoStreamIdentifier, cameraVideoStreamType)
        let screenShareVideoPair = (screenShareVideoStreamIdentifier, screenShareVideoStreamType)
        return screenShareVideoStreamIdentifier != nil ? screenShareVideoPair : cameraVideoPair
    }
}

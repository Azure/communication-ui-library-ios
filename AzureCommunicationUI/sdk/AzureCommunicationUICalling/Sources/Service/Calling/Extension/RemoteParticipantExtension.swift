//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation

extension AzureCommunicationCalling.RemoteParticipant {
    func toParticipantInfoModel(recentSpeakingStamp: Date) -> ParticipantInfoModel {
        let videoInfoModels: [VideoStreamInfoModel] = self.videoStreams.compactMap { videoStream in
            VideoStreamInfoModel(
                videoStreamIdentifier: String(videoStream.id),
                mediaStreamType: videoStream.mediaStreamType.converted())
        }

        let cameraVideoStreamModel = videoInfoModels.first(where: {$0.mediaStreamType == .cameraVideo})
        let screenShareVideoStreamModel = videoInfoModels.first(where: {$0.mediaStreamType == .screenSharing})

        return ParticipantInfoModel(displayName: displayName,
                                    isSpeaking: isSpeaking,
                                    isMuted: isMuted,
                                    isRemoteUser: true,
                                    userIdentifier: self.identifier.stringValue ?? "",
                                    status: state.toCompositeParticipantStatus(),
                                    recentSpeakingStamp: recentSpeakingStamp,
                                    screenShareVideoStreamModel: screenShareVideoStreamModel,
                                    cameraVideoStreamModel: cameraVideoStreamModel)
    }
}

extension AzureCommunicationCalling.MediaStreamType {
    func converted() -> VideoStreamInfoModel.MediaStreamType {
        switch self {
        case .screenSharing:
            return VideoStreamInfoModel.MediaStreamType.screenSharing
        case .video:
            return VideoStreamInfoModel.MediaStreamType.cameraVideo
        @unknown default:
            return VideoStreamInfoModel.MediaStreamType.cameraVideo
        }
    }

    var asUiMediaStreamType: MediaStreamType {
        switch self {
        case .screenSharing:
            return .screenSharing
        case .video:
            return .cameraVideo
        @unknown default:
            return .cameraVideo
        }
    }
}

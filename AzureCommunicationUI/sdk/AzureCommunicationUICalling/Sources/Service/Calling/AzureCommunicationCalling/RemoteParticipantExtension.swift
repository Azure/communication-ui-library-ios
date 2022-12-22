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
                                    userIdentifier: identifier.rawId,
                                    status: state.toCompositeParticipantStatus(),
                                    recentSpeakingStamp: recentSpeakingStamp,
                                    screenShareVideoStreamModel: screenShareVideoStreamModel,
                                    cameraVideoStreamModel: cameraVideoStreamModel)
    }

    static func toCompositeRemoteParticipant(
        acsRemoteParticipant: AzureCommunicationCalling.RemoteParticipant?
    ) -> CompositeRemoteParticipant< AzureCommunicationCalling.RemoteParticipant,
                            AzureCommunicationCalling.RemoteVideoStream>? {
        guard let remote = acsRemoteParticipant else {
            return nil
        }

        return CompositeRemoteParticipant(
            id: remote.identifier,
            videoStreams: remote.videoStreams
                .map(AzureCommunicationCalling.RemoteVideoStream.toCompositeRemoteVideoStream(acsRemoteVideoStream:)
                    ),
            wrappedObject: remote
        )
    }
}

extension AzureCommunicationCalling.RemoteVideoStream {
    static func toCompositeRemoteVideoStream(
        acsRemoteVideoStream: AzureCommunicationCalling.RemoteVideoStream
    ) -> CompositeRemoteVideoStream<AzureCommunicationCalling.RemoteVideoStream> {
        CompositeRemoteVideoStream(
            id: Int(acsRemoteVideoStream.id),
            mediaStreamType: acsRemoteVideoStream.mediaStreamType.asCompositeMediaStreamType,
            wrappedObject: acsRemoteVideoStream
        )
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

    var asCompositeMediaStreamType: CompositeMediaStreamType {
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

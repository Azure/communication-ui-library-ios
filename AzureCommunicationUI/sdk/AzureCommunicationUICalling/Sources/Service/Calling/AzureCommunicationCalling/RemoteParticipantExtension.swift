//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation

extension AzureCommunicationCalling.RemoteParticipant {
    func toParticipantInfoModel() -> ParticipantInfoModel {
        let videoInfoModels: [VideoStreamInfoModel] = self.incomingVideoStreams.compactMap { videoStream in
            VideoStreamInfoModel(
                videoStreamIdentifier: String(videoStream.id),
                mediaStreamType: videoStream.sourceType.converted())
        }

        let cameraVideoStreamModel = videoInfoModels.first(where: {$0.mediaStreamType == .cameraVideo})
        let screenShareVideoStreamModel = videoInfoModels.first(where: {$0.mediaStreamType == .screenSharing})

        return ParticipantInfoModel(displayName: displayName,
                                    isSpeaking: isSpeaking,
                                    isMuted: isMuted,
                                    isRemoteUser: true,
                                    userIdentifier: identifier.rawId,
                                    status: state.toCompositeParticipantStatus(),
                                    screenShareVideoStreamModel: screenShareVideoStreamModel,
                                    cameraVideoStreamModel: cameraVideoStreamModel)
    }

    static func toCompositeRemoteParticipant(
        acsRemoteParticipant: AzureCommunicationCalling.RemoteParticipant?
    ) -> CompositeRemoteParticipant< AzureCommunicationCalling.RemoteParticipant,
                            AzureCommunicationCalling.IncomingVideoStream>? {
        guard let remote = acsRemoteParticipant else {
            return nil
        }

        return CompositeRemoteParticipant(
            id: remote.identifier,
            videoStreams: remote.incomingVideoStreams
                .map(AzureCommunicationCalling.IncomingVideoStream.toCompositeRemoteVideoStream(acsRemoteVideoStream:)
                    ),
            wrappedObject: remote
        )
    }
}

extension AzureCommunicationCalling.IncomingVideoStream {
    static func toCompositeRemoteVideoStream(
        acsRemoteVideoStream: AzureCommunicationCalling.IncomingVideoStream
    ) -> CompositeRemoteVideoStream<AzureCommunicationCalling.IncomingVideoStream> {
        CompositeRemoteVideoStream(
            id: Int(acsRemoteVideoStream.id),
            mediaStreamType: acsRemoteVideoStream.sourceType.asCompositeMediaStreamType,
            wrappedObject: acsRemoteVideoStream
        )
    }
}

extension AzureCommunicationCalling.VideoStreamSourceType {
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

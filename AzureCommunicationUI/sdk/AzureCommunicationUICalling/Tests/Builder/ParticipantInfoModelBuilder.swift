//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

struct ParticipantInfoModelBuilder {
    static func get(participantIdentifier: String = UUID().uuidString,
                    videoStreamId: String? = "videoStreamId",
                    screenShareStreamId: String? = nil,
                    displayName: String = "displayName",
                    isSpeaking: Bool = false,
                    isMuted: Bool = true,
                    recentSpeakingStamp: Date = Date()) -> ParticipantInfoModel {
        var videoStreamInfoModel: VideoStreamInfoModel?
        var screenShareIdInfoModel: VideoStreamInfoModel?
        if let screenShareId = screenShareStreamId {
            screenShareIdInfoModel = VideoStreamInfoModel(videoStreamIdentifier: screenShareId,
                                                          mediaStreamType: .screenSharing)
        }

        if let cameraId = videoStreamId {
            videoStreamInfoModel = VideoStreamInfoModel(videoStreamIdentifier: cameraId,
                                                        mediaStreamType: .cameraVideo)
        }

        return ParticipantInfoModel(displayName: displayName,
                                    isSpeaking: isSpeaking,
                                    isMuted: isMuted,
                                    isRemoteUser: true,
                                    userIdentifier: participantIdentifier,
                                    status: .idle,
                                    recentSpeakingStamp: recentSpeakingStamp,
                                    screenShareVideoStreamModel: screenShareIdInfoModel,
                                    cameraVideoStreamModel: videoStreamInfoModel)
    }

    static func getArray(count: Int = 1) -> [ParticipantInfoModel] {
        var array = [ParticipantInfoModel]()
        for _ in 0..<count {
            array.append(get())
        }
        return array
    }
}

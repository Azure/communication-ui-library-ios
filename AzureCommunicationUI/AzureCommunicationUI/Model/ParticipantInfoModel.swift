//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantInfoModel: Hashable, Equatable {
    let displayName: String
    let isSpeaking: Bool
    let isMuted: Bool

    let isRemoteUser: Bool
    let userIdentifier: String

    let recentActiveStamp = Date()
    let recentSpeakingStamp: Date

    let screenShareVideoStreamModel: VideoStreamInfoModel?
    let cameraVideoStreamModel: VideoStreamInfoModel?

}

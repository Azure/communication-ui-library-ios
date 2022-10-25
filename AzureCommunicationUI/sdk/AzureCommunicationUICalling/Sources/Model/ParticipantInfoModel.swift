//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum ParticipantStatus: Int {
    case idle
    case earlyMedia
    case connecting
    case connected
    case hold
    case inLobby
    case disconnected
    case ringing
}

public struct ParticipantInfoModel: Hashable, Equatable {
    let displayName: String
    let isSpeaking: Bool
    let isMuted: Bool

    let isRemoteUser: Bool
    let userIdentifier: String
    let status: ParticipantStatus

    let recentSpeakingStamp: Date

    let screenShareVideoStreamModel: VideoStreamInfoModel?
    let cameraVideoStreamModel: VideoStreamInfoModel?

}

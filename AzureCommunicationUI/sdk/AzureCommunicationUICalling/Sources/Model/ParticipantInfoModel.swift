//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ParticipantStatus: Int {
    case idle
    case earlyMedia
    case connecting
    case connected
    case hold
    case inLobby
    case disconnected
    case ringing
}

struct ParticipantInfoModel: Hashable, Equatable {
    let displayName: String
    let isSpeaking: Bool
    let isMuted: Bool

    let isRemoteUser: Bool
    let userIdentifier: String
    let status: ParticipantStatus

    let screenShareVideoStreamModel: VideoStreamInfoModel?
    let cameraVideoStreamModel: VideoStreamInfoModel?
}

extension ParticipantInfoModel {
    static func from(localUserState: LocalUserState) -> ParticipantInfoModel {
        return ParticipantInfoModel(
            displayName: localUserState.displayName ?? "Unknown User", /* TADO: Look up localized*/
            isSpeaking: false,
            isMuted: false, /* TADO: Wire up*/
            isRemoteUser: false,
            userIdentifier: localUserState.displayName ?? "UU", /* TADO: Wire up properly*/
            status: ParticipantStatus.connected, /* TADO: Safe Assumption?*/
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil
        )
    }
}

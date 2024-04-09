//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == RemoteParticipantsState,
                        Actions == Action {
    static var liveRemoteParticipantsReducer: Self = Reducer { remoteParticipantsState, action in
        var participantInfoList = remoteParticipantsState.participantInfoList
        var lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
        var dominantSpeakers = remoteParticipantsState.dominantSpeakers
        var dominantSpeakersModifiedTimestamp
            = remoteParticipantsState.dominantSpeakersModifiedTimestamp
        var lobbyError = remoteParticipantsState.lobbyError

        switch action {
        case .remoteParticipantsAction(.dominantSpeakersUpdated(speakers: let newSpeakers)):
            dominantSpeakers = newSpeakers
            dominantSpeakersModifiedTimestamp = Date()
        case .remoteParticipantsAction(.participantListUpdated(participants: let newParticipants)):
            participantInfoList = newParticipants
            lastUpdateTimeStamp = Date()
        case .errorAction(.statusErrorAndCallReset):
            participantInfoList = []
            lastUpdateTimeStamp = Date()
        case .remoteParticipantsAction(.lobbyError(errorCode: let lobbyErrorCode)):
            if let lobbyErrorCode {
                lobbyError = LobbyError(lobbyErrorCode: lobbyErrorCode, errorTimeStamp: Date())
            } else {
                lobbyError = nil
            }

        default:
            break
        }
        return RemoteParticipantsState(participantInfoList: participantInfoList,
                                       lastUpdateTimeStamp: lastUpdateTimeStamp,
                                       dominantSpeakers: dominantSpeakers,
                                       dominantSpeakersModifiedTimestamp: dominantSpeakersModifiedTimestamp,
                                       lobbyError: lobbyError)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct RemoteParticipantsState {
    let participantInfoList: [ParticipantInfoModel]
    let lastUpdateTimeStamp: Date
    let dominantSpeakers: [String]
    let dominantSpeakersModifiedTimestamp: Date

    init(participantInfoList: [ParticipantInfoModel] = [],
         lastUpdateTimeStamp: Date = Date(),
         dominantSpeakers: [String] = [],
         dominantSpeakersModifiedTimestamp: Date = Date()) {
        self.participantInfoList = participantInfoList
        self.lastUpdateTimeStamp = lastUpdateTimeStamp
        self.dominantSpeakers = dominantSpeakers
        self.dominantSpeakersModifiedTimestamp = dominantSpeakersModifiedTimestamp
    }
}

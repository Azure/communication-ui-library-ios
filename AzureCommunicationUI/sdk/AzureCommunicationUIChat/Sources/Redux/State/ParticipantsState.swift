//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantsState {
    let participants: [String: ParticipantInfoModel]
    let localParticipantStatus: LocalParticipantStatus

    // MARK: Typing Indicators
    let participantsUpdatedTimestamp: Date
    let typingParticipants: [UserEventTimestampModel]

    var numberOfParticipants: Int {
        return participants.count
    }

    init(participants: [String: ParticipantInfoModel] = [:],
         participantsUpdatedTimestamp: Date = Date(),
         typingParticipants: [UserEventTimestampModel] = []
         localParticipantStatus: LocalParticipantStatus = .joined) {
        self.participants = participants
        self.localParticipantStatus = localParticipantStatus
        self.typingParticipants = typingParticipants
        self.participantsUpdatedTimestamp = participantsUpdatedTimestamp
    }
}

enum LocalParticipantStatus {
    case joined
    case removed
}

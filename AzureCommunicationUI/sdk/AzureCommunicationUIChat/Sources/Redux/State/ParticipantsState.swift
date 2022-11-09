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
    let typingIndicatorMap: [String: Date]
    let typingIndicatorUpdatedTimestamp: Date

    var numberOfParticipants: Int {
        return participants.count
    }

    init(participants: [String: ParticipantInfoModel] = [:],
         participantsUpdatedTimestamp: Date = Date(),
         typingIndicatorMap: [String: Date] = [:],
         typingIndicatorUpdatedTimestamp: Date = Date(),
         localParticipantStatus: LocalParticipantStatus = .joined) {
        self.participants = participants
        self.localParticipantStatus = localParticipantStatus
        self.participantsUpdatedTimestamp = participantsUpdatedTimestamp
        self.typingIndicatorMap = typingIndicatorMap
        self.typingIndicatorUpdatedTimestamp = typingIndicatorUpdatedTimestamp
    }
}

enum LocalParticipantStatus {
    case joined
    case removed
}

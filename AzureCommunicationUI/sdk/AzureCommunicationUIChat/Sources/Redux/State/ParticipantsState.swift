//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantsState {
    let participants: [String: ParticipantInfoModel]

    // MARK: Typing Indicators
    let participantsUpdatedTimestamp: Date
    let typingParticipants: [UserEventTimestampModel]

    // MARK: Read Receipt
    var readReceiptMap: [String: Date] = [:]
    var readReceiptUpdatedTimestamp: Date = .distantPast

    var numberOfParticipants: Int {
        return participants.count
    }

    init(participants: [String: ParticipantInfoModel] = [:],
         participantsUpdatedTimestamp: Date = Date(),
         typingParticipants: [UserEventTimestampModel] = [],
         readReceiptMap: [String: Date] = [:],
         readReceiptUpdatedTimestamp: Date = .distantPast) {
        self.participants = participants
        self.typingParticipants = typingParticipants
        self.participantsUpdatedTimestamp = participantsUpdatedTimestamp
        self.readReceiptMap = readReceiptMap
        self.readReceiptUpdatedTimestamp = readReceiptUpdatedTimestamp
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantsState {
    let participants: [String: ParticipantInfoModel]

    // MARK: Typing Indicators
    let participantsUpdatedTimestamp: Date
    let typingIndicatorMap: [String: Date]
    let typingIndicatorUpdatedTimestamp: Date

    // MARK: Read Receipt
    var readReceiptMap: [String: Date] = [:]
    var readReceiptUpdatedTimestamp: Date = .distantPast

    var numberOfParticipants: Int {
        return participants.count
    }

    init(participants: [String: ParticipantInfoModel] = [:],
         participantsUpdatedTimestamp: Date = Date(),
         typingIndicatorMap: [String: Date] = [:],
         typingIndicatorUpdatedTimestamp: Date = Date(),
         readReceiptMap: [String: Date] = [:],
         readReceiptUpdatedTimestamp: Date = .distantPast) {
        self.participants = participants

        self.participantsUpdatedTimestamp = participantsUpdatedTimestamp
        self.typingIndicatorMap = typingIndicatorMap
        self.typingIndicatorUpdatedTimestamp = typingIndicatorUpdatedTimestamp

        self.readReceiptMap = readReceiptMap
        self.readReceiptUpdatedTimestamp = readReceiptUpdatedTimestamp
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantsState {
    let participantsInfoMap: [String: ParticipantInfoModel]
    let readReceiptMap: [String: Date]
    let typingIndicatorMap: [String: Date]

    let participantsUpdatedTimestamp: Date
    let readReceiptUpdatedTimestamp: Date
    let typingIndicatorUpdatedTimestamp: Date

    init(participantsInfoMap: [String: ParticipantInfoModel] = [:],
         readReceiptMap: [String: Date] = [:],
         typingIndicatorMap: [String: Date] = [:],
         participantsUpdatedTimestamp: Date = Date(),
         readReceiptUpdatedTimestamp: Date = Date(),
         typingIndicatorUpdatedTimestamp: Date = Date()
    ) {
        self.participantsInfoMap = participantsInfoMap
        self.readReceiptMap = readReceiptMap
        self.typingIndicatorMap = typingIndicatorMap
        self.participantsUpdatedTimestamp = participantsUpdatedTimestamp
        self.readReceiptUpdatedTimestamp = readReceiptUpdatedTimestamp
        self.typingIndicatorUpdatedTimestamp = typingIndicatorUpdatedTimestamp
    }
}

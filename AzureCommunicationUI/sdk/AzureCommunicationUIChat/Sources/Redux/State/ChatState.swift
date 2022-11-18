//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ChatState {
    let localUser: ParticipantInfoModel?
    let threadId: String
    let topic: String
    let lastReadReceiptSentTimestamp: Date?
    let lastReceivedMessageTimestamp: Date
    let lastSentMessageTimestamp: Date
    let isLocalUserRemovedFromChat: Bool

    init(localUser: ParticipantInfoModel? = nil,
         threadId: String = "",
         topic: String = "",
         lastReadReceiptSentTimestamp: Date? = nil,
         lastReceivedMessageTimestamp: Date = Date(),
         lastSentMesssageTimestamp: Date = Date(),
         isLocalUserRemovedFromChat: Bool = false) {
        self.localUser = localUser
        self.threadId = threadId
        self.topic = topic
        self.lastReadReceiptSentTimestamp = lastReadReceiptSentTimestamp
        self.lastReceivedMessageTimestamp = lastReceivedMessageTimestamp
        self.lastSentMessageTimestamp = lastSentMesssageTimestamp
        self.isLocalUserRemovedFromChat = isLocalUserRemovedFromChat
    }
}

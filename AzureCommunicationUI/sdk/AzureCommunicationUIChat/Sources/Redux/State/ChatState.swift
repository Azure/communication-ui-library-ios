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
    let lastReadMessageId: String
    let lastReceivedMessageId: String
    let lastSentMessageId: String

    init(localUser: ParticipantInfoModel? = nil,
         threadId: String = "",
         topic: String = "",
         lastReadReceiptSentTimestamp: Date? = nil,
         lastReadMessageId: String = "",
         lastReceivedMessageId: String = "",
         lastSentMessageId: String = "") {
        self.localUser = localUser
        self.threadId = threadId
        self.topic = topic
        self.lastReadReceiptSentTimestamp = lastReadReceiptSentTimestamp
        self.lastReadMessageId = lastReadMessageId
        self.lastReceivedMessageId = lastReceivedMessageId
        self.lastSentMessageId = lastSentMessageId
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ChatState {
    let localUser: ParticipantInfoModel?
    let threadId: String
    let topic: String
    let lastReadReceiptReceivedTimestamp: Date
    let lastReadReceiptSentTimestamp: Date?
    let lastReceivedMessageTimestamp: Date
    let lastSendingMessageTimestamp: Date
    let lastSentOrFailedMessageTimestamp: Date
    let isLocalUserRemovedFromChat: Bool

    init(localUser: ParticipantInfoModel? = nil,
         threadId: String = "",
         topic: String = "",
         lastReadReceiptReceivedTimestamp: Date = Date(),
         lastReadReceiptSentTimestamp: Date? = nil,
         lastReceivedMessageTimestamp: Date = Date(),
         lastSendingMessageTimestamp: Date = Date(),
         lastSentOrFailedMessageTimestamp: Date = Date(),
         isLocalUserRemovedFromChat: Bool = false) {
        self.localUser = localUser
        self.threadId = threadId
        self.topic = topic
        self.lastReadReceiptReceivedTimestamp = lastReadReceiptReceivedTimestamp
        self.lastReadReceiptSentTimestamp = lastReadReceiptSentTimestamp
        self.lastReceivedMessageTimestamp = lastReceivedMessageTimestamp
        self.lastSendingMessageTimestamp = lastSendingMessageTimestamp
        self.lastSentOrFailedMessageTimestamp = lastSentOrFailedMessageTimestamp
        self.isLocalUserRemovedFromChat = isLocalUserRemovedFromChat
    }
}

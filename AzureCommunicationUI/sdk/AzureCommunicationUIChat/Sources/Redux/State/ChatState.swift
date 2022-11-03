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

    init(localUser: ParticipantInfoModel? = nil,
         threadId: String = "",
         topic: String = "",
         lastReadReceiptSentTimestamp: Date? = nil) {
        self.localUser = localUser
        self.threadId = threadId
        self.topic = topic
        self.lastReadReceiptSentTimestamp = lastReadReceiptSentTimestamp
    }
}

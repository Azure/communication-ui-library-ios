//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ChatState {
    let localUser: ParticipantInfoModel
    let threadId: String
    let topic: String

    init(localUser: ParticipantInfoModel,
         threadId: String,
         topic: String = "") {
        self.localUser = localUser
        self.threadId = threadId
        self.topic = topic
    }
}

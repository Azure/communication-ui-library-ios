//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ChatState {

    let localUser: LocalUserInfoModel
    let topic: String
    let messages: [ChatMessageInfoModel]
    let messagesLastUpdatedTimestamp: Date

    init(localUser: LocalUserInfoModel,
         topic: String = "",
         messages: [ChatMessageInfoModel] = [],
         messagesLastUpdatedTimestamp: Date = Date()) {
        self.localUser = localUser
        self.topic = topic
        self.messages = messages
        self.messagesLastUpdatedTimestamp = messagesLastUpdatedTimestamp
    }
}

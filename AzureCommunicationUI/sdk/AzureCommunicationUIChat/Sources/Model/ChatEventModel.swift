//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatEventType: Equatable {
    case realTimeNotificationConnected
    case realTimeNotificationDisconnected
    case chatMessageReceived
    case chatMessageEdited
    case chatMessageDeleted
    case typingIndicatorReceived
    case readReceiptReceived
    case chatThreadDeleted
    case chatThreadPropertiesUpdated
    case participantsAdded
    case participantsRemoved
}

struct ChatEventModel {
    let eventType: ChatEventType
    let infoModel: BaseInfoModel?
    let threadId: String?

    init(eventType: ChatEventType,
         infoModel: BaseInfoModel? = nil,
         threadId: String? = nil) {
        self.eventType = eventType
        self.infoModel = infoModel
        self.threadId = threadId
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCore
import Foundation

extension ChatMessageReceivedEvent {
    func toChatMessageInfoModel() -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            content: self.message,
            createdOn: self.createdOn)
    }
}

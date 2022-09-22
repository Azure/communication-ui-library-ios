//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationChat
import AzureCore

extension TypingIndicatorReceivedEvent {
    func toUserEventTimestampModel() -> UserEventTimestampModel {
        return UserEventTimestampModel(
            userIdentifier: self.sender,
            timestamp: self.receivedOn ?? Iso8601Date())
    }
}

extension ReadReceiptReceivedEvent {
    func toUserEventTimestampModel() -> UserEventTimestampModel {
        return UserEventTimestampModel(
            userIdentifier: self.sender,
            timestamp: self.readOn ?? Iso8601Date())
    }
}

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

extension ChatMessageEditedEvent {
    func toChatMessageInfoModel() -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            content: self.message,
            createdOn: self.createdOn,
            editedOn: self.editedOn)
    }
}

extension ChatMessageDeletedEvent {
    func toChatMessageInfoModel() -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            createdOn: self.createdOn,
            deletedOn: self.deletedOn)
    }
}

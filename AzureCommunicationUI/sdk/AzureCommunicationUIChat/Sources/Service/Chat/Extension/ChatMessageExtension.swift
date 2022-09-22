//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore
import AzureCommunicationChat

extension ChatMessage {
    func toChatMessageInfoModel() -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            internalId: UUID().uuidString,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            content: self.content?.message,
            createdOn: self.createdOn,
            editedOn: self.editedOn,
            deletedOn: self.deletedOn,
            participants: self.content?.participants?.map { $0.toParticipantInfoModel() } ?? [])
    }
}

extension ChatMessageType {
    func toMessageType() -> MessageType {
        switch self {
        case .custom(let str):
            return .custom(str)
        case .text:
            return .text
        case .html:
            return .html
        case .topicUpdated:
            return .topicUpdated
        case .participantAdded:
            return .participantsAdded
        case .participantRemoved:
            return .participantsRemoved
        }
    }
}

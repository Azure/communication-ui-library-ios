//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCommunicationCommon
import Foundation

extension ChatMessage {
    func toChatMessageInfoModel(localUserId: CommunicationIdentifier? = nil) -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            content: self.content?.message,
            createdOn: self.createdOn,
            editedOn: self.editedOn,
            deletedOn: self.deletedOn,
            participants: self.content?.participants?.map { $0.toParticipantInfoModel() } ?? [],
            isLocalUser: self.sender != nil && self.sender?.rawId == localUserId?.rawId)
    }
}

extension ChatMessageType {
    func toMessageType() -> MessageType {
        switch self {
        case .custom(let str):
            if str.lowercased() == "richtext/html" {
                return .html
            }
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

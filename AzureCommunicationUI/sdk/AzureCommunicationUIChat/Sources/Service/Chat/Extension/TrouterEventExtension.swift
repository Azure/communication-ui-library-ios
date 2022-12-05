//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCore
import Foundation

extension ChatMessageReceivedEvent {
    func toChatMessageInfoModel(localUserId: String) -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            content: self.message,
            createdOn: self.createdOn,
            isLocalUser: self.sender != nil && self.sender?.rawId == localUserId)
    }
}

extension ChatMessageEditedEvent {
    func toChatMessageInfoModel(localUserId: String) -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            content: self.message,
            createdOn: self.createdOn,
            editedOn: self.editedOn,
            isLocalUser: self.sender != nil && self.sender?.rawId == localUserId)
    }
}

extension ChatMessageDeletedEvent {
    func toChatMessageInfoModel(localUserId: String) -> ChatMessageInfoModel {
        return ChatMessageInfoModel(
            id: self.id,
            version: self.version,
            type: self.type.toMessageType(),
            senderId: self.sender?.stringValue,
            senderDisplayName: self.senderDisplayName,
            createdOn: self.createdOn,
            deletedOn: self.deletedOn,
            isLocalUser: self.sender != nil && self.sender?.rawId == localUserId)
    }
}

extension ChatThreadDeletedEvent {
    func toChatThreadInfoModel() -> ChatThreadInfoModel {
        return ChatThreadInfoModel(
            receivedOn: self.deletedOn ?? Iso8601Date())
    }
}

extension ChatThreadPropertiesUpdatedEvent {
    func toChatThreadInfoModel() -> ChatThreadInfoModel {
        return ChatThreadInfoModel(
            topic: self.properties?.topic,
            receivedOn: self.updatedOn ?? Iso8601Date())
    }
}

extension ParticipantsAddedEvent {
    func toParticipantsInfo(_ participantsAdded: [SignalingChatParticipant],
                            _ localParticipantId: CommunicationIdentifier) -> ParticipantsInfoModel {
        let participants = participantsAdded.map {
            $0.toParticipantInfoModel(localParticipantId.rawId)
        }
        return ParticipantsInfoModel(
            participants: participants,
            createdOn: self.addedOn ?? Iso8601Date())
    }
}

extension ParticipantsRemovedEvent {
    func toParticipantsInfo(_ participantsRemoved: [SignalingChatParticipant],
                            _ localParticipantId: CommunicationIdentifier) -> ParticipantsInfoModel {
        let participants = participantsRemoved.map {
            $0.toParticipantInfoModel(localParticipantId.rawId)
        }
        return ParticipantsInfoModel(
            participants: participants,
            createdOn: self.removedOn ?? Iso8601Date())
    }
}

extension TypingIndicatorReceivedEvent {
    func toUserEventTimestampModel() -> UserEventTimestampModel? {
        // device time is used to have consistent timer calculation
        return UserEventTimestampModel(
            userIdentifier: self.sender,
            timestamp: Iso8601Date())
    }
}

 extension ReadReceiptReceivedEvent {
    func toReadReceiptInfoModel() -> ReadReceiptInfoModel? {
        guard let sender = self.sender, let readOn = self.readOn else {
            return nil
        }
        return ReadReceiptInfoModel(
            senderIdentifier: sender,
            chatMessageId: self.chatMessageId,
            readOn: readOn)
    }
 }

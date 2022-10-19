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
    func toParticipantsInfo(_ participantsAdded: [SignalingChatParticipant]) -> ParticipantsInfoModel {
        let participants = participantsAdded.map {
            $0.toParticipantInfoModel()
        }
        return ParticipantsInfoModel(
            participants: participants)
    }
}

extension ParticipantsRemovedEvent {
    func toParticipantsInfo(_ participantsRemoved: [SignalingChatParticipant]) -> ParticipantsInfoModel {
        let participants = participantsRemoved.map {
            $0.toParticipantInfoModel()
        }
        return ParticipantsInfoModel(
            participants: participants)
    }
}

extension TypingIndicatorReceivedEvent {
    func toUserEventTimestampModel() -> UserEventTimestampModel? {
        return UserEventTimestampModel(
            userIdentifier: self.sender,
            timestamp: self.receivedOn)
    }
}

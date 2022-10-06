//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import AzureCommunicationCommon

enum MessageType: Equatable {
    case custom(String)
    case text
    case html
    case topicUpdated
    case participantsAdded
    case participantsRemoved
}

struct ChatMessageInfoModel: BaseInfoModel, Identifiable, Equatable, Hashable {
    var id: String
    let internalId: String
    let version: String
    let type: MessageType
    var senderId: String?
    var senderDisplayName: String?
    var content: String?
    var createdOn: Iso8601Date
    var editedOn: Iso8601Date?
    var deletedOn: Iso8601Date?

    // for participant added/removed only
    var participants: [ParticipantInfoModel]

    init(id: String? = nil,
         internalId: String? = nil,
         version: String = "",
         type: MessageType = .text,
         senderId: String? = nil,
         senderDisplayName: String? = nil,
         content: String? = nil,
         createdOn: Iso8601Date? = nil,
         editedOn: Iso8601Date? = nil,
         deletedOn: Iso8601Date? = nil,
         participants: [ParticipantInfoModel] = []) {
        self.id = id ?? internalId ?? UUID().uuidString
        self.internalId = internalId ?? UUID().uuidString
        self.version = version
        self.type = type
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.content = content
        self.createdOn = createdOn ?? Iso8601Date()
        self.editedOn = editedOn
        self.deletedOn = deletedOn
        self.participants = participants
    }

    mutating func replaceDummyId(realMessageId: String) {
        self.id = realMessageId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(internalId)
    }
}

extension ChatMessageInfoModel {
    func toChatMessage() -> ChatMessageModel {
        return ChatMessageModel(
            id: self.id,
            content: self.content ?? "not available",
            senderId: self.senderId ?? "",
            senderDisplayName: self.senderDisplayName ?? "")
    }
}

public struct ChatMessageModel {
    public let id: String
    public let content: String
    public let senderId: String
    public let senderDisplayName: String
}

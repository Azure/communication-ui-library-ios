//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore

enum MessageType: Equatable {
    case custom(String)
    case text
    case html
    case topicUpdated
    case participantsAdded
    case participantsRemoved
}

enum MessageSendStatus: Equatable {
    case sent
    case delivering
    case seen
    case failed
}

struct ChatMessageInfoModel: BaseInfoModel, Identifiable, Equatable, Hashable {
    var id: String
    let version: String
    let type: MessageType
    var senderId: String?
    var senderDisplayName: String?
    var content: String?
    var createdOn: Iso8601Date
    var editedOn: Iso8601Date?
    var deletedOn: Iso8601Date?
    var messageSendStatus: MessageSendStatus?

    // for participant added/removed only
    var participants: [ParticipantInfoModel]

    init(id: String? = nil,
         version: String = "",
         type: MessageType = .text,
         senderId: String? = nil,
         senderDisplayName: String? = nil,
         content: String? = nil,
         createdOn: Iso8601Date? = nil,
         editedOn: Iso8601Date? = nil,
         deletedOn: Iso8601Date? = nil,
         participants: [ParticipantInfoModel] = [],
         messageSendStatus: MessageSendStatus? = nil) {
        self.id = id ?? UUID().uuidString
        self.version = version
        self.type = type
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.content = content
        self.createdOn = createdOn ?? Iso8601Date()
        self.editedOn = editedOn
        self.deletedOn = deletedOn
        self.participants = participants
        self.messageSendStatus = messageSendStatus
    }

    mutating func replace(id: String) {
        self.id = id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

extension Iso8601Date {
    var dayOfYear: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self.value)!
    }
}

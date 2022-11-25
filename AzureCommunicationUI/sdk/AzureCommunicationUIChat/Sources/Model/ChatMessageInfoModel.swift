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
    var rawContent: String?
    var content: String?
    var createdOn: Iso8601Date
    var editedOn: Iso8601Date?
    var deletedOn: Iso8601Date?
    var sendStatus: MessageSendStatus?
    var isLocalUser: Bool

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
         sendStatus: MessageSendStatus? = nil,
         isLocalUser: Bool = false) {
        self.id = id ?? UUID().uuidString
        self.version = version
        self.type = type
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.rawContent = content
        if type == .html || type == .custom("RichText/Html") {
            self.content = content?.unescapeHtmlString
        } else {
            self.content = content
        }

        self.createdOn = createdOn ?? Iso8601Date()
        self.editedOn = editedOn
        self.deletedOn = deletedOn
        self.participants = participants
        self.sendStatus = sendStatus
        self.isLocalUser = isLocalUser
    }

    mutating func replace(id: String) {
        self.id = id
    }

    mutating func edit(content: String) {
        self.content = content
    }

    mutating func update(editedOn: Iso8601Date) {
        self.editedOn = editedOn
    }

    mutating func update(deletedOn: Iso8601Date) {
        self.deletedOn = deletedOn
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

// To be public for event handlers
struct ChatMessageModel {
    let id: String
    let content: String
    let senderId: String
    let senderDisplayName: String
}

extension Iso8601Date {
    var dayOfYear: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self.value)!
    }
}

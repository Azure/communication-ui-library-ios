//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

protocol MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] { get }

    // MARK: sending local events
    func addInitialMessages(initialMessages: [ChatMessageInfoModel])
    func addNewSendingMessage(message: ChatMessageInfoModel)
    func replaceMessageId(internalId: String, actualId: String)

    // MARK: receiving remote events
    func addReceivedMessage(message: ChatMessageInfoModel)
}

class MessageRepositoryManager: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    private let eventsHandler: ChatComposite.Events

    init(chatCompositeEventsHandler: ChatComposite.Events) {
        self.eventsHandler = chatCompositeEventsHandler

        messages = mockMessages()
    }

    func addInitialMessages(initialMessages: [ChatMessageInfoModel]) {
        messages = initialMessages
    }

    func addNewSendingMessage(message: ChatMessageInfoModel) {
        messages.append(message)
    }

    func replaceMessageId(internalId: String, actualId: String) {
        if let index = messages.firstIndex(where: {
            $0.id == internalId
        }) {
            var msg = messages[index]
            msg.replace(id: actualId)
            messages[index] = msg
        }
    }

    func addReceivedMessage(message: ChatMessageInfoModel) {
        if let index = messages.firstIndex(where: {
            $0.id == message.id
        }) {
            messages[index] = message
        } else {
            messages.append(message)
        }
    }
}

extension MessageRepositoryManager {
    func mockMessages() -> [ChatMessageInfoModel] {
        let today = Date()

        let message1 = ChatMessageInfoModel(id: "1",
                                             type: .text,
                                             senderId:
"8:acs:bcde2aa6-8666-4352-8e43-4286a7860fc7_00000013-0a79-14aa-f6c7-593a0d0042b4",
                                             senderDisplayName: "Patrick",
                                             content: "Hello Everyone",
                                            createdOn: Iso8601Date())
        let message2 = ChatMessageInfoModel(id: "2",
                                             type: .text,
                                             senderId:
"8:acs:bcde2aa6-8666-4352-8e43-4286a7860fc7_00000013-0a79-14aa-f6c7-593a0d0042b4",
                                             senderDisplayName: "Patrick",
                                             content: "How are you?",
                                             createdOn: Iso8601Date())

        let message3 = ChatMessageInfoModel(id: "3",
                                             type: .text,
                                             senderId: "KyleId",
                                             senderDisplayName: "Kyle",
                                             content: "Hello Patrick",
                                             createdOn: Iso8601Date())
        let message4 = ChatMessageInfoModel(id: "4",
                                            type: .participantsAdded,
                                             content: "System Message",
                                             createdOn: Iso8601Date())

        let message5 = ChatMessageInfoModel(id: "5",
                                             type: .text,
                                             senderId: "SamId",
                                             senderDisplayName: "Sam",
                                             content: "Hello Patrick and Klye",
                                             createdOn: Iso8601Date())
        var messages: [ChatMessageInfoModel] = []
        messages.append(message1)
        messages.append(message2)
        messages.append(message3)
        messages.append(message4)
        messages.append(message5)
        return messages
    }
}

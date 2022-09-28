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

    // MARK: receiving remote events
}

class MessageRepositoryManager: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    private let eventsHandler: ChatComposite.Events

    init(chatCompositeEventsHandler: ChatComposite.Events) {
        self.eventsHandler = chatCompositeEventsHandler
    }

    func addInitialMessages(initialMessages: [ChatMessageInfoModel]) {
        messages = initialMessages
    }
}

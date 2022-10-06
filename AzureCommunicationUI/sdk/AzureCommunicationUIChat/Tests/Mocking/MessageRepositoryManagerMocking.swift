//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class MessageRepositoryManagerMocking: MessageRepositoryManagerProtocol {
    var messages: [ChatMessageInfoModel] = []

    var addInitialMessagesCalled: Bool = false
    var addReceivedMessageCalled: Bool = false

    func addInitialMessages(initialMessages: [ChatMessageInfoModel]) {
        addInitialMessagesCalled = true
        messages = initialMessages
    }

    func addReceivedMessage(message: ChatMessageInfoModel) {
        addReceivedMessageCalled = true
        messages.append(message)
    }

}

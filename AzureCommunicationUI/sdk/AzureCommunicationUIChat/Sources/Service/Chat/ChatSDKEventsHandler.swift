//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationChat
import AzureCommunicationCommon

protocol ChatSDKEventsHandling {
    func handle(response: TrouterEvent)
}

class ChatSDKEventsHandler: NSObject, ChatSDKEventsHandling {
    private let logger: Logger
    private let threadId: String
    private let localUserId: CommunicationIdentifier

    init(logger: Logger,
         threadId: String,
         localUserId: CommunicationIdentifier) {
        self.logger = logger
        self.threadId = threadId
        self.localUserId = localUserId
    }

    func handle(response: TrouterEvent) {
        switch response {
        case let .chatMessageReceivedEvent(event):
            print("Received a ChatMessageReceivedEvent: \(event)")
        default:
            print("Event received will not handled \(response)")
            return
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCommunicationCommon
import Foundation

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
        case let .typingIndicatorReceived(event):
            // Stub: not implemented
            print("Received a TypingIndicatorReceivedEvent: \(event)")
        case let .readReceiptReceived(event):
            // Stub: not implemented
            print("Received a ReadReceiptReceivedEvent: \(event)")
        case let .chatMessageReceivedEvent(event):
            // Stub: not implemented
            print("Received a ChatMessageReceivedEvent: \(event)")
        case let .chatMessageEdited(event):
            // Stub: not implemented
            print("Received a ChatMessageEditedEvent: \(event)")
        case let .chatMessageDeleted(event):
            // Stub: not implemented
            print("Received a ChatMessageDeletedEvent: \(event)")
        case let .chatThreadPropertiesUpdated(event):
            // Stub: not implemented
            print("Received a ChatThreadPropertiesUpdatedEvent: \(event)")
        case let .chatThreadDeleted(event):
            // Stub: not implemented
            print("Received a ChatThreadDeletedEvent: \(event)")
        case let .participantsAdded(event):
            // Stub: not implemented
            print("Received a ParticipantsAddedEvent: \(event)")
        case let .participantsRemoved(event):
            // Stub: not implemented
            print("Received a ParticipantsRemovedEvent: \(event)")
        default:
            print("Event received will not handled \(response)")
            return
        }
    }
}

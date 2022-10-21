//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

protocol ParticipantsActionHandling {
    @discardableResult
    func sendReadReceipt(messageId: String, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
}

class ParticipantsActionHandler: ParticipantsActionHandling {
    private let chatService: ChatServiceProtocol
    private let logger: Logger

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    // MARK: Participants Handler
    func sendReadReceipt(messageId: String, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await chatService.sendReadReceipt(messageId: messageId)
                dispatch(.participantsAction(.sendReadReceiptSuccess(messageId: messageId)))
            } catch {
                logger.error("ParticipantsActionHandler sendReadReceipt failed: \(error)")
                dispatch(.participantsAction(.sendReadReceiptFailed(error: error as NSError)))
            }
        }
    }
}

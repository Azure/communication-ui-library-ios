//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class ThreadViewModel: ObservableObject {
    private let logger: Logger
    private let compositeViewModelFactory: CompositeViewModelFactory
    private let messageRepository: MessageRepositoryManagerProtocol
    private let dispatch: ActionDispatch
    private let localUser: LocalUserInfoModel

    private var participants: [ParticipantInfoModel] = []
    private var readReceiptLastUpdatedTimestamp = Date()
    private var messagesLastUpdatedTimestamp = Date()

    @Published var chatMessages: [ChatMessageInfoModel] = []
    @Published var lastMessageReadId: String?

    init(logger: Logger,
         compositeViewModelFactory: CompositeViewModelFactory,
         messageRepository: MessageRepositoryManagerProtocol,
         dispatch: @escaping ActionDispatch,
         localUser: LocalUserInfoModel) {
        self.logger = logger
        self.compositeViewModelFactory = compositeViewModelFactory
        self.messageRepository = messageRepository
        self.dispatch = dispatch
        self.localUser = localUser
    }

    func getPreviousMessages() {
        dispatch(.chatAction(.fetchPreviousMessagesTriggered))
    }

    func makeMessageViewModel(message: ChatMessageInfoModel, index: Int) -> MessageViewModel {
        compositeViewModelFactory.makeMessageViewModel(message: message,
                                                       index: index,
                                                       messages: chatMessages,
                                                       dispatch: dispatch,
                                                       localUser: localUser)
    }

    func isMessageRead(message: ChatMessageInfoModel, index: Int) -> Bool {
        print("READ RECEIPT - Message ID: \(message.id)")
        return message.senderId == localUser.localUserId &&
        ((lastMessageReadId == nil && index == chatMessages.count - 1)
         || lastMessageReadId == message.id)
    }

    func update(chatState: ChatState, participantsState: ParticipantsState) {
        if chatState.messagesLastUpdatedTimestamp != self.messagesLastUpdatedTimestamp {
            self.chatMessages = messageRepository.messages
            self.messagesLastUpdatedTimestamp = chatState.messagesLastUpdatedTimestamp
        }

        if participantsState.readReceiptUpdatedTimestamp != self.readReceiptLastUpdatedTimestamp {
            self.readReceiptLastUpdatedTimestamp = participantsState.readReceiptUpdatedTimestamp
            logger.debug("READ RECEIPT - OLD - Last Read Message Id: \(String(describing: lastMessageReadId))")
            self.lastMessageReadId = getMessageIdForLatestMessageReadByAllParticipants(
                readReceipts: participantsState.readReceiptMap)
            logger.debug("READ RECEIPT - NEW - Last Read Message Id: \(String(describing: lastMessageReadId))")
        }
    }

    private func getMessageIdForLatestMessageReadByAllParticipants(readReceipts: [String: Date]) -> String? {
        for readReceipt in readReceipts {
            logger.debug("READ RECEIPT - ReadReceipt Message ID: " +
                         "\(Int(readReceipt.value.timeIntervalSince1970 * 1000).requestString)")
        }

        let latestReadTimestamp = readReceipts.min { $0.value < $1.value }?.value
        if lastMessageReadId == nil {
            return nil
        }
        let latestReadMessageId = Int(latestReadTimestamp!.timeIntervalSince1970 * 1000).requestString

        logger.debug("READ RECEIPT - Latest Read Message Id: \(String(describing: latestReadMessageId))")

        return latestReadMessageId
    }
}

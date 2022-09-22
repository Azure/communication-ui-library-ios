//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageViewModel: ObservableObject {
    private let logger: Logger
    private let messages: [ChatMessageInfoModel]
    private let dispatch: ActionDispatch
    private let localUserId: String

    private var hasReadReceiptBeenSent: Bool = false

    let message: ChatMessageInfoModel
    let index: Int

    init(logger: Logger,
         message: ChatMessageInfoModel,
         index: Int,
         messages: [ChatMessageInfoModel],
         dispatch: @escaping ActionDispatch,
         localUser: LocalUserInfoModel) {
        self.logger = logger
        self.message = message
        self.index = index
        self.messages = messages
        self.dispatch = dispatch

        self.localUserId = localUser.localUserId ?? UUID().uuidString
    }

    func sendReadReceipt() {
        guard !hasReadReceiptBeenSent else {
            return
        }
        dispatch(.chatAction(.sendReadReceiptTriggered(messageId: message.id)))
        hasReadReceiptBeenSent = true
    }

    func isSelf() -> Bool {
        return message.senderId == localUserId
    }

    func isFirstRecentMessage() -> Bool {
        let minimumTimeDiff: Double = 600 // 10 Minutes

        if isFirstMessage() {
            return true
        }

        if messages[index].createdOn.value.timeIntervalSince1970
            - messages[index - 1].createdOn.value.timeIntervalSince1970
            >= minimumTimeDiff {
            return true
        }

        return false
    }

    func isConsecutiveMessage() -> Bool {
        if isFirstMessage() {
            return false
        }

        return isSameUser(messageOne: messages[index], messageTwo: messages[index - 1])
    }

    func getContentString() -> String {
        var content: String?
        if message.type == .text {
            content = message.content ?? "text not available"
        } else if message.type == .custom("RichText/Html") ||
                    message.type == .html {
            content = message.content?.replacingOccurrences(
                of: "<[^>]+>",
                with: "",
                options: String.CompareOptions.regularExpression)
        }
        return content ?? "text not available"
    }

    private func isFirstMessage() -> Bool {
        return index == 0
    }

    private func isSameUser(messageOne: ChatMessageInfoModel, messageTwo: ChatMessageInfoModel) -> Bool {
        return messageOne.senderId == messageTwo.senderId
    }
}

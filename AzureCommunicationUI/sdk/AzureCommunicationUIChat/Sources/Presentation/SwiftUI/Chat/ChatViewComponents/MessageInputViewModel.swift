//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationChat
import AzureCore
import Combine

class MessageInputViewModel: ObservableObject {
    private let typingIndicatorDelay: TimeInterval = 8.0

    private let logger: Logger
    private let dispatch: ActionDispatch
    private let localUserId: String
    private let displayName: String

    private var lastTypingIndicatorSendTimestamp = Date()

    init(logger: Logger,
         dispatch: @escaping ActionDispatch,
         localUser: LocalUserInfoModel) {
        self.logger = logger
        self.dispatch = dispatch

        self.localUserId = localUser.localUserId ?? UUID().uuidString
        self.displayName = localUser.displayName ?? "No Display Name"
    }

    func sendMessage(content: String) {
        let message = ChatMessageInfoModel(
            internalId: UUID().uuidString,
            type: .text,
            senderId: localUserId,
            senderDisplayName: displayName,
            content: content)
        dispatch(.chatAction(.sendMessageTriggered(message: message)))
    }

    func sendTypingIndicator() {
        if lastTypingIndicatorSendTimestamp < Date() - typingIndicatorDelay {
            dispatch(.chatAction(.sendTypingIndicatorTriggered))
            lastTypingIndicatorSendTimestamp = Date()
        }
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

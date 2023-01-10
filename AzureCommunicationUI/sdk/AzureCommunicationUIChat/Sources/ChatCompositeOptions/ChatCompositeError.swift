//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Chat Composite runtime error types.
public struct ChatCompositeErrorCode {
    /// Error when adapter fails to connect to a chat.
    public static let joinFailed: String = "joinFailed"
    /// Error when local user fails to send message.
    public static let sendMessageFailed: String = "sendMessageFailed"
    /// Error when local user fails to connect to real time notification service
    public static let startEventNotificationsFailed: String = "startEventNotificationsFailed"
    /// Error when trying to fetch the messages from service
    public static let fetchMessagesFailed: String = "fetchMessagesFailed"
    /// Error when trying to retrieve the participants in chat
    public static let requestParticipantsFetchFailed: String = "requestParticipantsFetchFailed"
    /// Error sending the read receipts up to the service
    public static let sendReadReceiptFailed: String = "sendReadReceiptFailed"
    /// Error sending the typing indicator event up to the service
    public static let sendTypingIndicatorFailed: String = "sendTypingIndicatorFailed"
    /// Error when a chat disconnects unexpectedly or fails on ending. (event code?)
    public static let disconnectFailed: String = "disconnectFailed"
}

/// The error thrown after Chat Composite launching.
public struct ChatCompositeError: Error {

    /// The string representing the ChatCompositeErrorCode.
    public let code: String

    /// The NSError returned from Azure Communication SDK.
    public var error: Error?
}

extension ChatCompositeError: Equatable {
    public static func == (lhs: ChatCompositeError, rhs: ChatCompositeError) -> Bool {
        if let error1 = lhs.error as NSError?,
           let error2 = rhs.error as NSError? {
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(error1.description)" == "\(error2.description)"
                && lhs.code == rhs.code
        }

        return false
    }
}

/// Event code (placeholder to be refactored)
struct ChatCompositeEventCode {
    /// Error when a participant is evicted from the chat by another participant (event code?)
    static let chatEvicted: String = "chatEvicted"

    /// Error when a participant is denied from entering the chat (event code?)
    static let chatDenied: String = "chatDenied"
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Chat Composite runtime error types.
struct ChatCompositeErrorCode {
    /// Error when adapter fails to connect to a chat.
    static let chatConnect: String = "chatConnect"

    /// Error when the input token is not authorized for the threadId.
    static let chatUnauthorized: String = "chatUnauthorized"

    /// Error when a chat disconnects unexpectedly or fails on ending. (event code?)
    static let chatEnd: String = "chatEnd"

    /// Error when a participant is evicted from the chat by another participant (event code?)
    static let chatEvicted: String = "chatEvicted"

    /// Error when a participant is denied from entering the chat (event code?)
    static let chatDenied: String = "chatDenied"

    /// Error when local user fails to send message.
    static let sendMessage: String = "sendMessage"
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

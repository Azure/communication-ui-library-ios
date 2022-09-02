//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Chat Composite runtime error types.
public struct ChatCompositeErrorCode {
    /// Error when local user fails to join a chat.
    public static let chatJoin: String = "chatJoin"

    /// Error when a chat disconnects unexpectedly or fails on ending.
    public static var chatEnd: String = "chatEnd"

    /// Error when the input token is expired.
    public static let tokenExpired: String = "tokenExpired"

    public static let showComposite: String = "showComposite"

    /// Error when a participant is evicted from the chat by another participant
    static let chatEvicted: String = "chatEvicted"

    /// Error when a participant is denied from entering the chat
    static let chatDenied: String = "chatDenied"

    /// Error when local user fails to hold a chat.
    static let chatHold: String = "chatHold"

    /// Error when local user fails to resume a chat.
    static let chatResume: String = "chatResume"
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

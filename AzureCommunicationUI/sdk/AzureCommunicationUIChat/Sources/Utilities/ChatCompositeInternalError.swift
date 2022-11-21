//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatCompositeInternalError: String, Error, Equatable {
    case chatConnectFailed
    case chatUnauthorized
    case chatEndFailed
    case chatEvicted
    case chatDenied
    case sendMessageFailed

    func toChatCompositeErrorCode() -> String? {
        switch self {
        case .chatConnectFailed:
            return ChatCompositeErrorCode.chatConnect
        case .chatUnauthorized:
            return ChatCompositeErrorCode.chatUnauthorized
        case .chatEndFailed:
            return ChatCompositeErrorCode.chatEnd
        case .chatEvicted:
            return ChatCompositeErrorCode.chatEvicted
        case .chatDenied:
            return ChatCompositeErrorCode.chatDenied
        case .sendMessageFailed:
            return ChatCompositeErrorCode.sendMessage
        }
    }

    func isFatalError() -> Bool {
        switch self {
        case .chatUnauthorized,
                .chatConnectFailed,
                .chatEndFailed,
                .chatEvicted:
            return true
        case .chatDenied,
                .sendMessageFailed:
            return false
        }
    }
}

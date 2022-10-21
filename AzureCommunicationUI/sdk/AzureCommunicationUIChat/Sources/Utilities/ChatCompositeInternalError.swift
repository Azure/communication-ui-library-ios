//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatCompositeInternalError: String, Error, Equatable {
    case chatTokenFailed
    case chatJoinFailed
    case chatEndFailed
    case chatEvicted
    case chatDenied
    case sendMessageFailed
    case parseThreadIdFailed

    func toChatCompositeErrorCode() -> String? {
        switch self {
        case .chatTokenFailed:
            return ChatCompositeErrorCode.tokenExpired
        case .chatJoinFailed:
            return ChatCompositeErrorCode.chatJoin
        case .chatEndFailed:
            return ChatCompositeErrorCode.chatEnd
        case .parseThreadIdFailed:
            return ChatCompositeErrorCode.parseThreadIdFailed
        case .sendMessageFailed:
            return ChatCompositeErrorCode.sendMessage
        case .chatEvicted:
            return ChatCompositeErrorCode.chatEvicted
        case .chatDenied:
            return nil
        }
    }

    func isFatalError() -> Bool {
        switch self {
        case .chatTokenFailed,
                .chatJoinFailed,
                .chatEndFailed,
                .parseThreadIdFailed,
                .chatEvicted:
            return true
        case .chatDenied,
                .sendMessageFailed:
            return false
        }
    }
}

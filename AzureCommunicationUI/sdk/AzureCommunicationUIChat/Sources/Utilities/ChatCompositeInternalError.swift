//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatCompositeInternalError: String, Error, Equatable {
    case chatTokenFailed
    case chatJoinFailed
    case chatEndFailed
    case chatHoldFailed
    case chatResumeFailed
    case chatEvicted
    case chatDenied

    func toChatCompositeErrorCode() -> String? {
        switch self {
        case .chatTokenFailed:
            return ChatCompositeErrorCode.tokenExpired
        case .chatJoinFailed:
            return ChatCompositeErrorCode.chatJoin
        case .chatEndFailed:
            return ChatCompositeErrorCode.chatEnd
        case .chatHoldFailed,
                .chatResumeFailed,
                .chatEvicted,
                .chatDenied:
            return nil
        }
    }

    func isFatalError() -> Bool {
        switch self {
        case .chatTokenFailed,
                .chatJoinFailed,
                .chatEndFailed:
            return true
        case .chatHoldFailed,
                .chatResumeFailed,
                .chatEvicted,
                .chatDenied:
            return false
        }
    }
}

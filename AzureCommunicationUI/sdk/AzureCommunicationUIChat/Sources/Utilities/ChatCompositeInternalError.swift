//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatCompositeInternalError: String, Error, Equatable {
    case connectFailed
    case disconnectFailed
    case typingIndicatorFailed
    case messageSendFailed
    case sendReadReceiptFailed
    case fetchMessagesFailed
    case requestParticipantsFetchFailed
    case sendMessageFailed

    // event code
    case chatEvicted
    case chatDenied

    func toChatCompositeErrorCode() -> String? {
        switch self {
        case .connectFailed:
            return ChatCompositeErrorCode.joinFailed
        case .disconnectFailed:
            return ChatCompositeErrorCode.disconnectFailed
        case .typingIndicatorFailed:
            return ChatCompositeErrorCode.sendTypingIndicatorFailed
        case .messageSendFailed:
            return ChatCompositeErrorCode.sendMessageFailed
        case .sendReadReceiptFailed:
            return ChatCompositeErrorCode.sendReadReceiptFailed
        case .fetchMessagesFailed:
            return ChatCompositeErrorCode.fetchMessagesFailed
        case .requestParticipantsFetchFailed:
            return ChatCompositeErrorCode.requestParticipantsFetchFailed
        case .sendMessageFailed:
            return ChatCompositeErrorCode.sendMessageFailed
        case .chatEvicted:
            return ChatCompositeEventCode.chatEvicted
        case .chatDenied:
            return ChatCompositeEventCode.chatDenied

        }
    }

    func isFatalError() -> Bool {
        switch self {
        case .connectFailed,
                .disconnectFailed:
            return true
        case .typingIndicatorFailed,
                .messageSendFailed,
                .sendReadReceiptFailed,
                .fetchMessagesFailed,
                .requestParticipantsFetchFailed,
                .sendMessageFailed,
                .chatDenied,
                .chatEvicted:
            return false
        }
    }
}

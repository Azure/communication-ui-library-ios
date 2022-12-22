//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatCompositeInternalError: String, Error, Equatable {
    case connectFailed
    case authorizationFailed
    case disconnectFailed
    case messageSendFailed

    // event code
    case chatEvicted
    case chatDenied

    func toChatCompositeErrorCode() -> String? {
        switch self {
        case .connectFailed:
            return ChatCompositeErrorCode.connectFailed
        case .authorizationFailed:
            return ChatCompositeErrorCode.authorizationFailed
        case .disconnectFailed:
            return ChatCompositeErrorCode.disconnectFailed
        case .chatEvicted:
            return ChatCompositeEventCode.chatEvicted
        case .chatDenied:
            return ChatCompositeEventCode.chatDenied
        case .messageSendFailed:
            return ChatCompositeErrorCode.messageSendFailed
        }
    }

    func isFatalError() -> Bool {
        switch self {
        case .connectFailed,
                .authorizationFailed,
                .disconnectFailed:
            return true
        case .chatDenied,
                .chatEvicted,
                .messageSendFailed:
            return false
        }
    }
}

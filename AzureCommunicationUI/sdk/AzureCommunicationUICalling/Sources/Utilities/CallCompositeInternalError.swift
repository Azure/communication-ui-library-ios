//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CallCompositeInternalError: Error, Equatable {
    case deviceManagerFailed(Error?)
    case connectionFailed
    case callTokenFailed
    case callJoinFailed
    case callEndFailed
    case callHoldFailed
    case callResumeFailed
    case callEvicted
    case callDenied
    case cameraSwitchFailed
    case cameraOnFailed

    func toCallCompositeErrorCode() -> String? {
        switch self {
        case .deviceManagerFailed:
            return CallCompositeErrorCode.cameraFailure
        case .callTokenFailed:
            return CallCompositeErrorCode.tokenExpired
        case .callJoinFailed:
            return CallCompositeErrorCode.callJoin
        case .callEndFailed:
            return CallCompositeErrorCode.callEnd
        case .cameraOnFailed:
            return CallCompositeErrorCode.cameraFailure
        case .callHoldFailed,
                .callResumeFailed,
                .callEvicted,
                .callDenied,
                .cameraSwitchFailed,
                .connectionFailed:
            return nil
        }
    }

    func isFatalError() -> Bool {
        switch self {
        case .deviceManagerFailed,
                .callTokenFailed,
                .callJoinFailed,
                .callEndFailed:
            return true
        case .callHoldFailed,
                .callResumeFailed,
                .callEvicted,
                .callDenied,
                .cameraSwitchFailed,
                .cameraOnFailed,
                .connectionFailed:
            return false
        }
    }
}

extension CallCompositeInternalError {
    static func == (lhs: CallCompositeInternalError, rhs: CallCompositeInternalError) -> Bool {
        switch(lhs, rhs) {
        case (.deviceManagerFailed, .deviceManagerFailed),
            (.connectionFailed, .connectionFailed),
            (.callTokenFailed, .callTokenFailed),
            (.callJoinFailed, .callJoinFailed),
            (.callEndFailed, .callEndFailed),
            (.callHoldFailed, .callHoldFailed),
            (.callResumeFailed, .callResumeFailed),
            (.callEvicted, .callEvicted),
            (.callDenied, .callDenied),
            (.cameraSwitchFailed, .cameraSwitchFailed),
            (.cameraOnFailed, .cameraOnFailed):
            return true
        default:
            return false
        }
    }
}

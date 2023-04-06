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
    case callJoinFailedByMicPermission
    case cameraSwitchFailed
    case cameraOnFailed
    case networkConnectionNotAvailable

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
        case .callJoinFailedByMicPermission:
            return CallCompositeErrorCode.microphonePermissionNotGranted
        case .networkConnectionNotAvailable:
            return CallCompositeErrorCode.networkConnectionNotAvailable
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
                .callJoinFailedByMicPermission,
                .networkConnectionNotAvailable,
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
            (.networkConnectionNotAvailable, .networkConnectionNotAvailable),
            (.cameraOnFailed, .cameraOnFailed):
            return true
        default:
            return false
        }
    }
}

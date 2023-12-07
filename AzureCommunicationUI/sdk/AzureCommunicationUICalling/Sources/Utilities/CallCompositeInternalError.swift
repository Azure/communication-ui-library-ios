//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CallCompositeInternalError: Error, Equatable {
    case deviceManagerFailed(Error?)
    case callJoinConnectionFailed
    case callTokenFailed
    case canNotMakeCall
    case callJoinFailed
    case callEndFailed
    case callHoldFailed
    case callResumeFailed
    case callEvicted
    case callDenied
    case callDeclined
    case callJoinFailedByMicPermission
    case cameraSwitchFailed
    case cameraOnFailed
    case networkConnectionNotAvailable
    case micNotAvailable

    func toCallCompositeErrorCode() -> String? {
        switch self {
        case .deviceManagerFailed:
            return CallCompositeErrorCode.cameraFailure
        case .callTokenFailed:
            return CallCompositeErrorCode.tokenExpired
        case .callJoinFailed, .callJoinConnectionFailed:
            return CallCompositeErrorCode.callJoin
        case .callEndFailed:
            return CallCompositeErrorCode.callEnd
        case .canNotMakeCall:
            return CallCompositeErrorCode.canNotMakeCall
        case .callDeclined:
            return CallCompositeErrorCode.callDeclined
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
                .callJoinConnectionFailed,
                .micNotAvailable,
                .cameraSwitchFailed:
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
                .callEndFailed,
                .callDeclined,
                .canNotMakeCall:
            return true
        case .callHoldFailed,
                .callResumeFailed,
                .callEvicted,
                .callDenied,
                .cameraSwitchFailed,
                .cameraOnFailed,
                .micNotAvailable,
                .callJoinConnectionFailed:
            return false
        }
    }
}

extension CallCompositeInternalError {
    static func == (lhs: CallCompositeInternalError, rhs: CallCompositeInternalError) -> Bool {
        switch(lhs, rhs) {
        case (.deviceManagerFailed, .deviceManagerFailed),
            (.callJoinConnectionFailed, .callJoinConnectionFailed),
            (.callTokenFailed, .callTokenFailed),
            (.callDeclined, .callDeclined),
            (.canNotMakeCall, .canNotMakeCall),
            (.callJoinFailed, .callJoinFailed),
            (.callEndFailed, .callEndFailed),
            (.callHoldFailed, .callHoldFailed),
            (.callResumeFailed, .callResumeFailed),
            (.callEvicted, .callEvicted),
            (.callDenied, .callDenied),
            (.cameraSwitchFailed, .cameraSwitchFailed),
            (.networkConnectionNotAvailable, .networkConnectionNotAvailable),
            (.cameraOnFailed, .cameraOnFailed),
            (.micNotAvailable, .micNotAvailable):
            return true
        default:
            return false
        }
    }
}

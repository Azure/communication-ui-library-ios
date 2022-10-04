//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Call Composite runtime error types.
public struct CallCompositeErrorCode {
    /// Error when local user fails to join a call.
    public static let callJoin: String = "callJoin"

    /// Error when a call disconnects unexpectedly or fails on ending.
    public static let callEnd: String = "callEnd"

    /// Error when camera failed to start or stop
    public static let cameraFailure: String = "cameraFailure"

    /// Error when the input token is expired.
    public static let tokenExpired: String = "tokenExpired"

    /// Error when a participant is evicted from the call by another participant
    static let callEvicted: String = "callEvicted"

    /// Error when a participant is denied from entering the call
    static let callDenied: String = "callDenied"

    /// Error when local user fails to hold a call.
    static let callHold: String = "callHold"

    /// Error when local user fails to resume a call.
    static let callResume: String = "callResume"
}

/// The error thrown after Call Composite launching.
public struct CallCompositeError {

    /// The string representing the CallCompositeErrorCode.
    public let code: String

    /// The NSError returned from Azure Communication SDK.
    public let error: Error?
}

extension CallCompositeError: Equatable {
    public static func == (lhs: CallCompositeError, rhs: CallCompositeError) -> Bool {
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

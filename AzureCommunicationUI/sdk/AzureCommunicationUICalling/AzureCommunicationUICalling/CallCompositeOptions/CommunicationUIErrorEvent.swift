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
    public static var callEnd: String = "callEnd"

    /// Error when the input token is expired.
    public static let tokenExpired: String = "tokenExpired"

    /// Error when the remote participant is not found in the call.
    public static let remoteParticipantNotFound: String = "RemoteParticipantNotFound"

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
public struct CommunicationUIErrorEvent: Error {

    /// The string representing the CallCompositeErrorCode.
    public let code: String

    /// The NSError returned from Azure Communication SDK.
    public var error: Error?
}

extension CommunicationUIErrorEvent: Equatable {
    public static func == (lhs: CommunicationUIErrorEvent, rhs: CommunicationUIErrorEvent) -> Bool {
        if let error1 = lhs.error as NSError?,
           let error2 = rhs.error as NSError? {
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(error1.description)" == "\(error2.description)"
                && lhs.code == rhs.code
        }

        if let error1 = lhs.error as? CompositeError?,
           let error2 = rhs.error as? CompositeError? {
            return error1 == error2 && lhs.code == rhs.code
        }

        return false
    }
}

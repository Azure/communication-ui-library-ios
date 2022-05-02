//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

protocol BaseCallCompositeErrorCode {
    static var callJoin: String { get }
    static var callEnd: String { get }
    static var tokenExpired: String { get }
}

/// Call Composite runtime error types.
public struct CallCompositeErrorCode: BaseCallCompositeErrorCode {

    /// Error when local user fails to join a call. 
    public private(set) static var callJoin: String = "callJoin"

    /// Error when a call disconnects unexpectedly or fails on ending.
    public private(set) static var callEnd: String = "callEnd"

    /// Error when the input token is expired.
    public private(set) static var tokenExpired: String = "tokenExpired"
}

struct InternalCallCompositeErrorCode: BaseCallCompositeErrorCode {
    /// Error when local user fails to join a call.
    static var callJoin: String = "callJoin"

    /// Error when a call disconnects unexpectedly or fails on ending.
    static var callEnd: String = "callEnd"

    /// Error when the input token is expired.
    static var tokenExpired: String = "tokenExpired"

    /// Error when a participant is evicted from the call by another participant
    static var callEvicted: String = "callEvicted"
}

/// The error thrown after Call Composite launching.
public struct CommunicationUIErrorEvent {

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

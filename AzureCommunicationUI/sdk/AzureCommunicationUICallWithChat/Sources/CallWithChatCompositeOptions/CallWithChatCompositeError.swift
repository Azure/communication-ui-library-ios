//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// CallWithChat Composite runtime error types.
public struct CallWithChatCompositeErrorCode {
}

/// The error thrown after CallWithChat Composite launching.
public struct CallWithChatCompositeError {

    /// The string representing the CallWithChatCompositeErrorCode.
    public let code: String

    /// The NSError returned from Azure Communication SDK.
    public var error: Error?
}

extension CallWithChatCompositeError: Equatable {
    public static func == (lhs: CallWithChatCompositeError, rhs: CallWithChatCompositeError) -> Bool {
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

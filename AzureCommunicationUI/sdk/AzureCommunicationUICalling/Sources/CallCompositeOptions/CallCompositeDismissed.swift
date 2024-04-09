//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// The error thrown after Call Composite launching.
public struct CallCompositeDismissed {
    /// The string representing the CallCompositeErrorCode.
    public let errorCode: String?

    /// The NSError.
    public let error: Error?
}

extension CallCompositeDismissed: Equatable {
    public static func == (lhs: CallCompositeDismissed, rhs: CallCompositeDismissed) -> Bool {
        if let error1 = lhs.error as NSError?,
           let error2 = rhs.error as NSError? {
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(error1.description)" == "\(error2.description)"
                && lhs.errorCode == rhs.errorCode
        }

        return false
    }
}

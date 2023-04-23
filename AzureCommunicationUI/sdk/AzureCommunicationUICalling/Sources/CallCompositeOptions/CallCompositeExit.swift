//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// The error thrown after Call Composite launching.
public struct CallCompositeExit {
    /// The NSError returned from Azure Communication SDK.
    public let error: Error?
}

extension CallCompositeExit: Equatable {
    public static func == (lhs: CallCompositeExit, rhs: CallCompositeExit) -> Bool {
        if let error1 = lhs.error as NSError?,
           let error2 = rhs.error as NSError? {
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(error1.description)" == "\(error2.description)"
        }

        return false
    }
}

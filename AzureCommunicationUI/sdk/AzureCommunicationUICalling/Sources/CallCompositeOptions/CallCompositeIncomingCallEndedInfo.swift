//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Incoming call end info.
public struct CallCompositeIncomingCallEndedInfo {
    /// call end code
    public let code: Int

    /// call end sub code
    public let subCode: Int

    /// Create an instance of a CallCompositeIncomingCallEndedInfo with incoming call ended info.
    /// - Parameters:
    ///   - code: Call end code.
    ///   - subCode: Call end sub code.
    public init(code: Int,
                subCode: Int) {
        self.code = code
        self.subCode = subCode
    }
}

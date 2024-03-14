//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Incoming call cancelled..
public struct CallCompositeIncomingCallCancelled {
    /// Call id.
    public let callId: String
    /// call cancelled code
    public let code: Int
    /// call cancelled sub code
    public let subCode: Int

    /// Create an instance of a CallCompositeIncomingCallCanceledInfo.
    /// - Parameters:
    ///   - callId: call id.
    ///   - code: Call cancelled code.
    ///   - subCode: Call end sub code.
    init(callId: String,
         code: Int,
         subCode: Int) {
        self.callId = callId
        self.code = code
        self.subCode = subCode
    }
}

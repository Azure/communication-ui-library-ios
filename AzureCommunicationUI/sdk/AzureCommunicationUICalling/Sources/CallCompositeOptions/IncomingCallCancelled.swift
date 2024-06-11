//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Incoming call cancelled..
public struct IncomingCallCancelled {
    /// Call id.
    public let callId: String
    /// call cancelled code
    public let code: Int
    /// call cancelled sub code
    public let subCode: Int
}

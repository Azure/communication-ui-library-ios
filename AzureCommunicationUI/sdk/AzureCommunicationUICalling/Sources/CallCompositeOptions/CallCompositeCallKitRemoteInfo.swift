//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit info for caller(incoming)/callee(outgoing)
public struct CallCompositeCallKitRemoteInfo {
    /// Display name of the remote participant
    let displayName: String

    /// CXHandle of the remote participant, for call history
    let cxHandle: CXHandle

    public init(displayName: String,
                cxHandle: CXHandle) {
        self.displayName = displayName
        self.cxHandle = cxHandle
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit remote participant info for the call to display in call history.
public struct CallCompositeCallKitRemoteInfo {
    /// Display name of the remote participant
    let displayName: String

    /// CXHandle of the remote participant
    let cxHandle: CXHandle

    public init(displayName: String,
                cxHandle: CXHandle) {
        self.displayName = displayName
        self.cxHandle = cxHandle
    }
}

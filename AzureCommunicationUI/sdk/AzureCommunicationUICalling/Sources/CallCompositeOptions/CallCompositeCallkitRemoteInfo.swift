//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

public struct CallCompositeCallKitRemoteInfo {
    let displayName: String
    let cxHandle: CXHandle

    public init(displayName: String,
                cxHandle: CXHandle) {
        self.displayName = displayName
        self.cxHandle = cxHandle
    }
}

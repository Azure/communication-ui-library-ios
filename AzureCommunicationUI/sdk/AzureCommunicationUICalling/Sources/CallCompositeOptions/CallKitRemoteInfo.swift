//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit

/// CallKit data for callee(outgoing)
public struct CallKitRemoteInfo {
    /// Display name of the remote participant
    public let displayName: String

    /// CXHandle of the remote participant, for call history
    public let handle: CXHandle
}

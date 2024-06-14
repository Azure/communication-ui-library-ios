//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Incoming call..
public struct IncomingCall {
    /// Call id.
    public let callId: String
    /// Caller display name.
    public let callerDisplayName: String
    /// Caller CommunicationIdentifier.
    public let callerIdentifier: CommunicationIdentifier
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Incoming call info.
public struct CallCompositeIncomingCallInfo {
    /// Call id.
    public let callId: String
    /// Caller display name.
    public let callerDisplayName: String
    /// Caller CommunicationIdentifier.
    public let callerIdentifier: CommunicationIdentifier

    /// Create an instance of a CallCompositeIncomingCallInfo.
    /// - Parameters:
    ///   - callId: call id.
    ///   - callerDisplayName: Caller display name.
    ///   - callerIdentifier: Caller CommunicationIdentifier.
    public init(callId: String,
                callerDisplayName: String,
                callerIdentifier: CommunicationIdentifier) {
        self.callId = callId
        self.callerDisplayName = callerDisplayName
        self.callerIdentifier = callerIdentifier
    }
}

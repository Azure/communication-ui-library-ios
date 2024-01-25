//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct CallCompositeIncomingCallInfo {
    /// Call id.
    public let callId: String

    /// Caller disply name.
    public let callerDisplayName: String

    /// Caller raw id
    public let callerIdentifierRawId: String

    /// Create an instance of a CallCompositePushNotificationInfo with push notification payload.
    /// - Parameters:
    ///   - callId: call id.
    ///   - callerDisplayName: Caller display name.
    ///   - callerIdentifierRawId: Caller raw id.
    public init(callId: String,
                callerDisplayName: String,
                callerIdentifierRawId: String) {
        self.callId = callId
        self.callerDisplayName = callerDisplayName
        self.callerIdentifierRawId = callerIdentifierRawId
    }
}

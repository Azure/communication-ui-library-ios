//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal struct CallCompositeIncomingCallInfo {
    /// Call id.
    let callId: String

    /// Caller disply name.
    let callerDisplayName: String

    /// Caller raw id
    let callerIdentifierRawId: String

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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct CallCompositeCallerInfo {

    /// Caller disply name.
    let callerDisplayName: String

    /// Caller raw id
    let callerIdentifierRawId: String

    /// Create an instance of a CallCompositePushNotificationInfo with push notification payload.
    /// - Parameters:
    ///   - callerDisplayName: Caller display name.
    ///   - callerIdentifierRawId: Caller raw id.
    public init(callerDisplayName: String,
                callerIdentifierRawId: String) {
        self.callerDisplayName = callerDisplayName
        self.callerIdentifierRawId = callerIdentifierRawId
    }
}

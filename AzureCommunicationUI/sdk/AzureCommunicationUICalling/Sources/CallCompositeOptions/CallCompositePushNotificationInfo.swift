//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

/// CallCompositePushNotificationInfo with PushNotificationInfo containing call information
public struct CallCompositePushNotificationInfo {
    /// push notification info
    public let pushNotificationInfo: PushNotificationInfo

    /// Create an instance of a CallCompositePushNotificationInfo with push notification payload.
    /// - Parameters:
    ///   - pushNotificationInfo: Push notification payload.
    public init(pushNotificationInfo: [AnyHashable: Any]) {
        self.pushNotificationInfo = PushNotificationInfo.fromDictionary(pushNotificationInfo)
    }
}

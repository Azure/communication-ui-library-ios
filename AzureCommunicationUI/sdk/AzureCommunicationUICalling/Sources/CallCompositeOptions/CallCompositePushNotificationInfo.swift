//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

public struct CallCompositePushNotificationInfo {
    let pushNotificationInfo: PushNotificationInfo

    public init(pushNotificationInfo: [AnyHashable: Any]) {
        self.pushNotificationInfo = PushNotificationInfo.fromDictionary(pushNotificationInfo)
    }
}

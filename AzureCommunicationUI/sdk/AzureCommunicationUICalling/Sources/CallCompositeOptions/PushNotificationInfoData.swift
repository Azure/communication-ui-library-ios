//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct PushNotificationInfoData {
    let notificationInfo: [AnyHashable: Any]
    public init(notificationInfo: [AnyHashable: Any]) {
        self.notificationInfo = notificationInfo
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ToastNotificationAction: Equatable {
    case showNotification(kind: ToastNotificationKind)
    case dismissNotification
}

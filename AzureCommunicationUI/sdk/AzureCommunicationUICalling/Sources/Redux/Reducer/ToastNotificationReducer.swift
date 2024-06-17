//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == ToastNotificationState,
                        Actions == ToastNotificationAction {
    static var toastNotificationReducer: Self = Reducer { currentState, action in
        var newStatus = currentState.status
        switch action {
        case .showNotification(let kind):
            newStatus = kind
        case .dismissNotification:
            newStatus = nil
        }
        return ToastNotificationState(status: newStatus)
    }
}

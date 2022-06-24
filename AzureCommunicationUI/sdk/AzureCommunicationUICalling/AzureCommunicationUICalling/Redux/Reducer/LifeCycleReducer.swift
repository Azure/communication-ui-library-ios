//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

let liveLifecycleReducer = Reducer<LifeCycleState, LifecycleAction> { appLifeCycleCurrentState, action in

    var currentStatus = appLifeCycleCurrentState.currentStatus
    switch action {
    case .foregroundEntered:
        currentStatus = .foreground
    case .backgroundEntered:
        currentStatus = .background
    default:
        return appLifeCycleCurrentState
    }
    return LifeCycleState(currentStatus: currentStatus)
}

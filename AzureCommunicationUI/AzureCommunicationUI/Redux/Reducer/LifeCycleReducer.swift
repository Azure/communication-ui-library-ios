//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct LifeCycleReducer: Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let appLifeCycleCurrentState = state as? LifeCycleState else {
            return state
        }
        var currentStatus = appLifeCycleCurrentState.currentStatus
        switch action {
        case _ as LifecycleAction.ForegroundEntered:
            currentStatus = .foreground
        case _ as LifecycleAction.BackgroundEntered:
            currentStatus = .background
        default:
            return appLifeCycleCurrentState
        }
        return LifeCycleState(currentStatus: currentStatus)
    }
}

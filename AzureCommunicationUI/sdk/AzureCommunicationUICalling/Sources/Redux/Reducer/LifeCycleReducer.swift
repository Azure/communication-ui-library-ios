//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == LifeCycleState,
                        Actions == LifecycleAction {
    static var liveLifecycleReducer: Self = Reducer { appLifeCycleCurrentState, action in

        var currentStatus = appLifeCycleCurrentState.currentStatus
        switch action {
        case .foregroundEntered:
            currentStatus = .foreground
        case .backgroundEntered:
            currentStatus = .background
        case .willTerminate:
            currentStatus = .willTerminate
        }
        return LifeCycleState(currentStatus: currentStatus)
    }
}

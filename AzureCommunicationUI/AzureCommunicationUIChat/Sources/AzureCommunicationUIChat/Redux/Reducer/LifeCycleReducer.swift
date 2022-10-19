//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

extension Reducer where State == LifeCycleState,
                        Actions == Action {
    static var liveLifecycleReducer: Self = Reducer { appLifeCycleCurrentState, action in
        var currentStatus = appLifeCycleCurrentState.currentStatus
        switch action {
        case .lifecycleAction(.foregroundEntered):
            currentStatus = .foreground
        case .lifecycleAction(.backgroundEntered):
            currentStatus = .background
        default:
            break
        }
        return LifeCycleState(currentStatus: currentStatus)
    }
}

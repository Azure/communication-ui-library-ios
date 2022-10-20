//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
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
        }
        return LifeCycleState(currentStatus: currentStatus)
    }
}

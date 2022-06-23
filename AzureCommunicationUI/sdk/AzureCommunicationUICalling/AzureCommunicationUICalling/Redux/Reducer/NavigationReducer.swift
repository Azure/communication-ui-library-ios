//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

let navigationReducer = Reducer<NavigationState, Actions> { state, action in
    var navigationStatus = state.status
    switch action {
    case .lifecycleAction(.callingViewLaunched):
        navigationStatus = .inCall
    case .callingAction(.dismissSetup),
            .lifecycleAction(.compositeExitAction):
        navigationStatus = .exit
    case .errorAction(.statusErrorAndCallReset):
        navigationStatus = .setup
    default:
        return state
    }
    return NavigationState(status: navigationStatus)
}
